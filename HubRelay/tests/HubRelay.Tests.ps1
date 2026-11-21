#Requires -Version 7.0
<#
.SYNOPSIS
    Pester-compatible / standalone tests for HubRelay (fictional hosts only).
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$manifest = Join-Path $PSScriptRoot '..' 'src' 'HubRelay' 'HubRelay.psd1' | Resolve-Path
Import-Module $manifest -Force

$script:Failed = 0
$script:Passed = 0

function Assert-True {
    param([bool]$Condition, [string]$Name)
    if ($Condition) {
        Write-Host "  PASS  $Name"
        $script:Passed++
    }
    else {
        Write-Host "  FAIL  $Name"
        $script:Failed++
    }
}

Write-Host 'HubRelay tests'
Write-Host '--------------'

# Allowlist
try {
    $null = New-HubJob -Playbook 'NotARealPlaybook' -DryRun
    Assert-True -Condition $false -Name 'Reject unknown playbook'
}
catch {
    Assert-True -Condition $true -Name 'Reject unknown playbook'
}

$job = New-HubJob -Playbook 'Get-ServiceHealth' -DryRun -Targets @('relay-alpha')
Assert-True -Condition ($job.Status -eq 'Succeeded') -Name 'DryRun Get-ServiceHealth succeeds'
Assert-True -Condition ($job.Id -match '^[a-f0-9]{32}$') -Name 'Job id is 32-char hex'

$fetched = Get-HubJob -Id $job.Id
Assert-True -Condition ($fetched.Id -eq $job.Id) -Name 'Get-HubJob returns job'

$summary = Get-HubJobSummary -Id $job.Id
Assert-True -Condition ($summary.Playbook -eq 'Get-ServiceHealth') -Name 'Summary playbook name'
Assert-True -Condition ($null -ne $summary.Result) -Name 'Summary includes redacted result'

# Redaction
$leaky = New-HubJob -Playbook 'Get-ServiceHealth' -Simulation -Targets @('relay-bravo') `
    -Parameters @{ ServiceName = 'hubrelay-agent'; Note = 'token=supersecretVALUE password=hunter2' }
# Inject sensitive text into stored result for redaction check
$stored = Get-HubJob -Id $leaky.Id
$stored | Add-Member -NotePropertyName Error -NotePropertyValue 'Bearer abcdef123456 password=hunter2 user@example.com' -Force
$redacted = Get-HubJobSummary -Id $leaky.Id
$errText = [string]$redacted.Error
Assert-True -Condition ($errText -notmatch 'abcdef123456') -Name 'Redacts bearer token material'
Assert-True -Condition ($errText -match '\[REDACTED' -or $errText -match 'REDACTED') -Name 'Redaction markers present'

$smoke = Test-HubRelay
Assert-True -Condition ($smoke.Passed -eq $true) -Name 'Test-HubRelay passes'

# Listener round-trip
$env:HUBRELAY_TOKEN = 'test-token-hubrelay-0001-do-not-commit'
try {
    Stop-HubRelay -ErrorAction SilentlyContinue
    $meta = Start-HubRelay -Port 8765 -Simulation -Token $env:HUBRELAY_TOKEN -PassThru
    Assert-True -Condition ($meta.Prefix -match '127\.0\.0\.1:8765') -Name 'Listener binds loopback:8765'
    Start-Sleep -Milliseconds 400

    $headers = @{ Authorization = "Bearer $($env:HUBRELAY_TOKEN)" }
    $health = Invoke-RestMethod -Uri 'http://127.0.0.1:8765/v1/health' -Headers $headers
    Assert-True -Condition ($health.status -eq 'ok') -Name 'GET /v1/health'

    $body = @{
        playbook   = 'Clear-TempSafe'
        targets    = @('relay-charlie')
        dryRun     = $true
        simulation = $true
    } | ConvertTo-Json
    $created = Invoke-RestMethod -Uri 'http://127.0.0.1:8765/v1/jobs' -Headers $headers `
        -Method Post -ContentType 'application/json' -Body $body
    Assert-True -Condition ($created.Status -in @('Succeeded', 'DryRun', 'CompletedWithErrors') -or $created.DryRun -eq $true) -Name 'POST /v1/jobs'

    $remoteSummary = Invoke-RestMethod -Uri "http://127.0.0.1:8765/v1/jobs/$($created.Id)/summary" -Headers $headers
    Assert-True -Condition ($remoteSummary.Id -eq $created.Id) -Name 'GET /v1/jobs/{id}/summary'

    try {
        Invoke-RestMethod -Uri 'http://127.0.0.1:8765/v1/health' -Headers @{ Authorization = 'Bearer wrong' } -ErrorAction Stop
        Assert-True -Condition $false -Name 'Reject bad token'
    }
    catch {
        Assert-True -Condition $true -Name 'Reject bad token'
    }
}
finally {
    Stop-HubRelay
    Remove-Item Env:HUBRELAY_TOKEN -ErrorAction SilentlyContinue
}

Write-Host '--------------'
Write-Host "Passed: $script:Passed  Failed: $script:Failed"
if ($script:Failed -gt 0) { exit 1 } else { exit 0 }
