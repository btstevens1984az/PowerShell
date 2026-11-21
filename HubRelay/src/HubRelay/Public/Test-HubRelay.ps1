function Test-HubRelay {
    <#
    .SYNOPSIS
        Smoke-tests HubRelay allowlist, in-process jobs, and optional listener health.
    .PARAMETER IncludeListener
        Also GET /v1/health when the listener is running.
    .PARAMETER BaseUrl
        Listener base URL. Default http://127.0.0.1:8765
    #>
    [CmdletBinding()]
    param(
        [switch] $IncludeListener,

        [string] $BaseUrl = 'http://127.0.0.1:8765',

        [string] $Token
    )

    $checks = [System.Collections.Generic.List[object]]::new()

    # Allowlist / playbook files
    foreach ($name in $script:HubRelayState.Allowlist) {
        try {
            $null = Assert-Allowlist -Playbook $name
            $checks.Add([pscustomobject]@{ Name = "Allowlist:$name"; Ok = $true; Detail = 'ok' })
        }
        catch {
            $checks.Add([pscustomobject]@{ Name = "Allowlist:$name"; Ok = $false; Detail = $_.Exception.Message })
        }
    }

    # In-process dry-run job
    try {
        $job = New-HubJob -Playbook 'Get-ServiceHealth' -DryRun -Targets @('relay-alpha')
        $sum = Get-HubJobSummary -Id $job.Id
        $ok = ($job.Status -eq 'Succeeded') -and ($null -ne $sum.Id)
        $checks.Add([pscustomobject]@{ Name = 'InProcessJob'; Ok = $ok; Detail = "status=$($job.Status)" })
    }
    catch {
        $checks.Add([pscustomobject]@{ Name = 'InProcessJob'; Ok = $false; Detail = $_.Exception.Message })
    }

    # Reject non-allowlisted playbook
    try {
        $null = New-HubJob -Playbook 'Invoke-Dangerous' -DryRun -ErrorAction Stop
        $checks.Add([pscustomobject]@{ Name = 'RejectUnknownPlaybook'; Ok = $false; Detail = 'unexpectedly accepted' })
    }
    catch {
        $checks.Add([pscustomobject]@{ Name = 'RejectUnknownPlaybook'; Ok = $true; Detail = 'rejected as expected' })
    }

    if ($IncludeListener) {
        if (-not $script:HubRelayState.IsRunning) {
            $checks.Add([pscustomobject]@{ Name = 'ListenerHealth'; Ok = $false; Detail = 'listener not running' })
        }
        else {
            try {
                $tok = if ($Token) { $Token } elseif ($env:HUBRELAY_TOKEN) { $env:HUBRELAY_TOKEN } else { $null }
                $headers = @{}
                if ($tok) { $headers['Authorization'] = "Bearer $tok" }
                $resp = Invoke-RestMethod -Uri "$BaseUrl/v1/health" -Headers $headers -Method Get -TimeoutSec 5
                $checks.Add([pscustomobject]@{ Name = 'ListenerHealth'; Ok = ($resp.status -eq 'ok'); Detail = ($resp | ConvertTo-Json -Compress) })
            }
            catch {
                $checks.Add([pscustomobject]@{ Name = 'ListenerHealth'; Ok = $false; Detail = $_.Exception.Message })
            }
        }
    }

    $failed = @($checks | Where-Object { -not $_.Ok })
    return [pscustomobject]@{
        Passed = ($failed.Count -eq 0)
        Checks = $checks.ToArray()
    }
}
