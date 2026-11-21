function Start-HubRelay {
    <#
    .SYNOPSIS
        Starts the HubRelay localhost control-plane HTTP listener.
    .DESCRIPTION
        Binds HttpListener to 127.0.0.1 by default on an uncommon port (8765).
        Authenticates with a shared bearer token from -Token or env HUBRELAY_TOKEN.
        Never commit tokens. No telemetry is emitted.
    .PARAMETER Port
        TCP port. Default 8765.
    .PARAMETER BindAddress
        Listener bind address. Default 127.0.0.1 (loopback only).
    .PARAMETER Token
        Shared bearer token. Prefer $env:HUBRELAY_TOKEN. If omitted and env is empty, a token is generated and printed once.
    .PARAMETER Simulation
        Run all jobs in simulation mode (offline demos).
    .PARAMETER DryRun
        Default DryRun for jobs that do not specify otherwise.
    .PARAMETER RateLimitPerMinute
        Simple in-memory request rate limit per client window. Default 60.
    .PARAMETER PassThru
        Return listener metadata object.
    #>
    [CmdletBinding()]
    param(
        [ValidateRange(1024, 65535)]
        [int] $Port = 8765,

        [ValidateSet('127.0.0.1', 'localhost')]
        [string] $BindAddress = '127.0.0.1',

        [string] $Token,

        [switch] $Simulation,

        [switch] $DryRun,

        [ValidateRange(1, 10000)]
        [int] $RateLimitPerMinute = 60,

        [switch] $PassThru
    )

    if ($script:HubRelayState.IsRunning) {
        throw "HubRelay is already running on $($script:HubRelayState.Prefix)"
    }

    $resolvedToken = $Token
    if ([string]::IsNullOrWhiteSpace($resolvedToken)) {
        $resolvedToken = $env:HUBRELAY_TOKEN
    }
    $generated = $false
    if ([string]::IsNullOrWhiteSpace($resolvedToken)) {
        $resolvedToken = New-SignedToken
        $env:HUBRELAY_TOKEN = $resolvedToken
        $generated = $true
    }

    $script:HubRelayState.TokenHash = Get-HubTokenHash -Token $resolvedToken
    $script:HubRelayState.Simulation = [bool]$Simulation
    $script:HubRelayState.DryRunDefault = [bool]$DryRun
    $script:HubRelayState.RateLimitPerMinute = $RateLimitPerMinute
    $script:HubRelayState.RequestTimestamps.Clear()
    $script:HubRelayState.RequestCount = 0
    $script:HubRelayState.StartedAt = [datetime]::UtcNow

    $hostName = if ($BindAddress -eq 'localhost') { 'localhost' } else { '127.0.0.1' }
    $prefix = "http://${hostName}:${Port}/"
    $script:HubRelayState.Prefix = $prefix

    $listener = [System.Net.HttpListener]::new()
    $listener.Prefixes.Add($prefix)

    try {
        $listener.Start()
    }
    catch {
        throw "Failed to start HttpListener on $prefix. Ensure the port is free and you have permission. $($_.Exception.Message)"
    }

    $script:HubRelayState.Listener = $listener
    $script:HubRelayState.IsRunning = $true

    # Shared state bag for the background runspace
    $stateBag = [hashtable]::Synchronized(@{
            Listener           = $listener
            Jobs               = $script:HubRelayState.Jobs
            TokenHash          = $script:HubRelayState.TokenHash
            Simulation         = $script:HubRelayState.Simulation
            DryRunDefault      = $script:HubRelayState.DryRunDefault
            RateLimitPerMinute = $script:HubRelayState.RateLimitPerMinute
            RequestTimestamps  = $script:HubRelayState.RequestTimestamps
            RateLock           = New-Object object
            RequestCount       = 0
            Allowlist          = $script:HubRelayState.Allowlist
            PlaybookRoot       = $script:HubRelayState.PlaybookRoot
            SimulatedFleet     = $script:HubRelayState.SimulatedFleet
            StartedAt          = $script:HubRelayState.StartedAt
            ModuleRoot         = $PSScriptRoot
            StopFlag           = [hashtable]::Synchronized(@{ Stop = $false })
        })

    $script:HubRelayState.StopFlag = $stateBag.StopFlag

    $runspace = [runspacefactory]::CreateRunspace()
    $runspace.Open()
    $runspace.SessionStateProxy.SetVariable('HubState', $stateBag)

    $ps = [powershell]::Create()
    $ps.Runspace = $runspace

    $null = $ps.AddScript({
            Set-StrictMode -Version Latest
            $ErrorActionPreference = 'Stop'

            function Get-Sha256Hex([string] $Text) {
                $sha = [System.Security.Cryptography.SHA256]::Create()
                try {
                    $hash = $sha.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($Text))
                    return ([BitConverter]::ToString($hash) -replace '-', '').ToLowerInvariant()
                }
                finally { $sha.Dispose() }
            }

            function Test-Auth([System.Net.HttpListenerRequest] $Req) {
                $header = $Req.Headers['Authorization']
                if ([string]::IsNullOrWhiteSpace($header) -or -not $header.StartsWith('Bearer ', [StringComparison]::OrdinalIgnoreCase)) {
                    return $false
                }
                $presented = $header.Substring(7).Trim()
                if ([string]::IsNullOrEmpty($presented)) { return $false }
                $presentedHash = Get-Sha256Hex $presented
                $a = [System.Text.Encoding]::UTF8.GetBytes($presentedHash)
                $b = [System.Text.Encoding]::UTF8.GetBytes([string]$HubState.TokenHash)
                if ($a.Length -ne $b.Length) { return $false }
                $diff = 0
                for ($i = 0; $i -lt $a.Length; $i++) { $diff = $diff -bor ($a[$i] -bxor $b[$i]) }
                return ($diff -eq 0)
            }

            function Test-Rate() {
                $now = [datetime]::UtcNow
                $windowStart = $now.AddMinutes(-1)
                $list = $HubState.RequestTimestamps
                $lockObj = $HubState.RateLock
                [void][System.Threading.Monitor]::Enter($lockObj)
                try {
                    while ($list.Count -gt 0 -and $list[0] -lt $windowStart) { $list.RemoveAt(0) }
                    if ($list.Count -ge [int]$HubState.RateLimitPerMinute) { return $false }
                    $list.Add($now)
                    return $true
                }
                finally {
                    [System.Threading.Monitor]::Exit($lockObj)
                }
            }

            function Write-JsonResponse([System.Net.HttpListenerResponse] $Res, [int] $StatusCode, $Body) {
                $json = if ($Body -is [string]) { $Body } else { $Body | ConvertTo-Json -Depth 10 -Compress }
                $bytes = [System.Text.Encoding]::UTF8.GetBytes($json)
                $Res.StatusCode = $StatusCode
                $Res.ContentType = 'application/json; charset=utf-8'
                $Res.Headers['X-Content-Type-Options'] = 'nosniff'
                $Res.Headers['Cache-Control'] = 'no-store'
                $Res.ContentLength64 = $bytes.LongLength
                $Res.OutputStream.Write($bytes, 0, $bytes.Length)
                $Res.OutputStream.Close()
            }

            function Invoke-Redact($InputObject) {
                if ($null -eq $InputObject) { return $null }
                $patterns = @(
                    '(?i)(bearer\s+)[A-Za-z0-9\-._~+/]+=*',
                    '(?i)(token["''\s:=]+)[A-Za-z0-9\-._~+/]+=*',
                    '(?i)(password["''\s:=]+)\S+',
                    '(?i)(api[_-]?key["''\s:=]+)\S+',
                    '(?i)(secret["''\s:=]+)\S+',
                    '(?i)[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}',
                    '(?i)(/home/|/Users/)[^\s/]+'
                )
                $replacements = @(
                    '${1}[REDACTED]', '${1}[REDACTED]', '${1}[REDACTED]', '${1}[REDACTED]',
                    '${1}[REDACTED]', '[REDACTED-EMAIL]', '${1}[REDACTED-USER]'
                )
                $text = if ($InputObject -is [string]) { $InputObject } else { $InputObject | ConvertTo-Json -Depth 8 -Compress }
                for ($i = 0; $i -lt $patterns.Count; $i++) {
                    $text = [regex]::Replace($text, $patterns[$i], $replacements[$i])
                }
                if ($InputObject -is [string]) { return $text }
                try { return ($text | ConvertFrom-Json) } catch { return $text }
            }

            function New-JobFromBody([hashtable] $Body) {
                $playbook = [string]$Body.playbook
                if ([string]::IsNullOrWhiteSpace($playbook)) { throw 'playbook is required' }
                $name = [System.IO.Path]::GetFileNameWithoutExtension($playbook)
                if ($name -notin @($HubState.Allowlist)) {
                    throw "Playbook '$name' is not allowlisted. Allowed: $($HubState.Allowlist -join ', ')"
                }
                $path = Join-Path $HubState.PlaybookRoot "$name.ps1"
                if (-not (Test-Path -LiteralPath $path)) { throw "Playbook file missing: $name.ps1" }

                $dryRun = if ($Body.ContainsKey('dryRun')) { [bool]$Body.dryRun } else { [bool]$HubState.DryRunDefault }
                $simulation = if ($Body.ContainsKey('simulation')) { [bool]$Body.simulation } else { [bool]$HubState.Simulation }
                $targets = @()
                if ($Body.ContainsKey('targets') -and $null -ne $Body.targets) {
                    $targets = @($Body.targets | ForEach-Object { [string]$_ })
                }
                $parameters = @{}
                if ($Body.ContainsKey('parameters') -and $null -ne $Body.parameters) {
                    foreach ($k in $Body.parameters.Keys) { $parameters[$k] = $Body.parameters[$k] }
                }

                $fleet = if ($targets.Count -gt 0) {
                    $targets | ForEach-Object { @{ Name = $_ } }
                } else {
                    @($HubState.SimulatedFleet)
                }

                $jobId = [guid]::NewGuid().ToString('n')
                $created = [datetime]::UtcNow
                $results = [System.Collections.Generic.List[object]]::new()

                foreach ($node in $fleet) {
                    $nodeName = if ($node -is [hashtable]) { [string]$node['Name'] } else { [string]$node.Name }
                    if ($dryRun -or $simulation) {
                        $results.Add([pscustomobject]@{
                                Target = $nodeName; Playbook = $name
                                Status = $(if ($dryRun) { 'DryRun' } else { 'Simulated' })
                                Output = "Would run $name on $nodeName"
                                StartedAt = [datetime]::UtcNow; EndedAt = [datetime]::UtcNow
                            })
                        continue
                    }
                    $started = [datetime]::UtcNow
                    try {
                        $output = & $path @parameters -Target $nodeName
                        $results.Add([pscustomobject]@{
                                Target = $nodeName; Playbook = $name; Status = 'Succeeded'
                                Output = $output; StartedAt = $started; EndedAt = [datetime]::UtcNow
                            })
                    }
                    catch {
                        $results.Add([pscustomobject]@{
                                Target = $nodeName; Playbook = $name; Status = 'Failed'
                                Output = $_.Exception.Message; StartedAt = $started; EndedAt = [datetime]::UtcNow
                            })
                    }
                }

                $fanOut = [pscustomobject]@{ Playbook = $name; DryRun = $dryRun; Results = $results.ToArray() }
                $failed = @($results | Where-Object { $_.Status -eq 'Failed' })
                $status = if ($failed.Count -gt 0) { 'CompletedWithErrors' } else { 'Succeeded' }

                $record = [pscustomobject]@{
                    Id          = $jobId
                    Playbook    = $name
                    Parameters  = $parameters
                    Targets     = $targets
                    DryRun      = $dryRun
                    Simulation  = $simulation
                    Status      = $status
                    CreatedAt   = $created
                    StartedAt   = $created
                    CompletedAt = [datetime]::UtcNow
                    Result      = $fanOut
                    Error       = $null
                }
                $null = $HubState.Jobs.TryAdd($jobId, $record)
                return $record
            }

            $listener = $HubState.Listener
            while (-not $HubState.StopFlag.Stop -and $listener.IsListening) {
                $ctxResult = $null
                try {
                    $async = $listener.BeginGetContext($null, $null)
                    while (-not $async.IsCompleted) {
                        if ($HubState.StopFlag.Stop) { break }
                        Start-Sleep -Milliseconds 100
                    }
                    if ($HubState.StopFlag.Stop) { break }
                    $ctx = $listener.EndGetContext($async)
                }
                catch {
                    if ($HubState.StopFlag.Stop -or -not $listener.IsListening) { break }
                    continue
                }

                $req = $ctx.Request
                $res = $ctx.Response
                try {
                    $HubState.RequestCount = [int]$HubState.RequestCount + 1

                    if (-not (Test-Rate)) {
                        Write-JsonResponse $res 429 @{ error = 'rate_limit_exceeded' }
                        continue
                    }

                    $path = $req.Url.AbsolutePath.TrimEnd('/')
                    if ([string]::IsNullOrEmpty($path)) { $path = '/' }

                    # Health is authenticated to avoid unauthenticated probing
                    if (-not (Test-Auth $req)) {
                        Write-JsonResponse $res 401 @{ error = 'unauthorized' }
                        continue
                    }

                    if ($req.HttpMethod -eq 'GET' -and $path -eq '/v1/health') {
                        Write-JsonResponse $res 200 @{
                            status    = 'ok'
                            version   = '0.1.0'
                            startedAt = $HubState.StartedAt
                            jobs      = $HubState.Jobs.Count
                            simulation = [bool]$HubState.Simulation
                            bind      = 'loopback'
                        }
                        continue
                    }

                    if ($req.HttpMethod -eq 'POST' -and $path -eq '/v1/jobs') {
                        $reader = [System.IO.StreamReader]::new($req.InputStream, $req.ContentEncoding)
                        try { $raw = $reader.ReadToEnd() }
                        finally { $reader.Dispose() }
                        if ([string]::IsNullOrWhiteSpace($raw)) {
                            Write-JsonResponse $res 400 @{ error = 'empty_body' }
                            continue
                        }
                        try {
                            $bodyObj = $raw | ConvertFrom-Json -AsHashtable
                            $job = New-JobFromBody -Body $bodyObj
                            Write-JsonResponse $res 201 $job
                        }
                        catch {
                            Write-JsonResponse $res 400 @{ error = 'bad_request'; message = $_.Exception.Message }
                        }
                        continue
                    }

                    if ($req.HttpMethod -eq 'GET' -and $path -match '^/v1/jobs/([a-f0-9]{32})$') {
                        $id = $Matches[1]
                        $job = $null
                        if ($HubState.Jobs.TryGetValue($id, [ref]$job)) {
                            Write-JsonResponse $res 200 $job
                        }
                        else {
                            Write-JsonResponse $res 404 @{ error = 'not_found' }
                        }
                        continue
                    }

                    if ($req.HttpMethod -eq 'GET' -and $path -match '^/v1/jobs/([a-f0-9]{32})/summary$') {
                        $id = $Matches[1]
                        $job = $null
                        if (-not $HubState.Jobs.TryGetValue($id, [ref]$job)) {
                            Write-JsonResponse $res 404 @{ error = 'not_found' }
                            continue
                        }
                        $summary = @{
                            Id          = $job.Id
                            Playbook    = $job.Playbook
                            Status      = $job.Status
                            DryRun      = $job.DryRun
                            Simulation  = $job.Simulation
                            CreatedAt   = $job.CreatedAt
                            StartedAt   = $job.StartedAt
                            CompletedAt = $job.CompletedAt
                            Error       = Invoke-Redact $job.Error
                            Result      = Invoke-Redact $job.Result
                        }
                        Write-JsonResponse $res 200 $summary
                        continue
                    }

                    Write-JsonResponse $res 404 @{ error = 'not_found'; path = $path }
                }
                catch {
                    try { Write-JsonResponse $res 500 @{ error = 'internal_error' } } catch { }
                }
            }
        })

    $handle = $ps.BeginInvoke()
    $script:HubRelayState.Runspace = $runspace
    $script:HubRelayState.PowerShell = $ps
    $script:HubRelayState.AsyncHandle = $handle

    Write-Host "HubRelay listening on $prefix (loopback only)"
    Write-Host "Auth: Authorization: Bearer `$env:HUBRELAY_TOKEN"
    if ($generated) {
        Write-Host "Generated HUBRELAY_TOKEN for this session (not persisted). Export it before client calls."
        Write-Host "Token length: $($resolvedToken.Length) chars"
    }
    if ($Simulation) { Write-Host 'Mode: Simulation' }
    if ($DryRun) { Write-Host 'Mode: DryRun default' }

    # Clear local secret material from this scope
    $resolvedToken = $null

    if ($PassThru) {
        return [pscustomobject]@{
            Prefix             = $prefix
            Port               = $Port
            BindAddress        = $hostName
            Simulation         = [bool]$Simulation
            DryRun             = [bool]$DryRun
            RateLimitPerMinute = $RateLimitPerMinute
            TokenGenerated     = $generated
            StartedAt          = $script:HubRelayState.StartedAt
        }
    }
}
