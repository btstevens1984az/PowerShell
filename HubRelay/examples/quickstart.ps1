#Requires -Version 7.0
<#
.SYNOPSIS
    HubRelay quickstart — fictional fleet only, no real inventory.
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$moduleManifest = Join-Path $PSScriptRoot '..' 'src' 'HubRelay' 'HubRelay.psd1' | Resolve-Path
Import-Module $moduleManifest -Force

# Demo token for local session only — never commit real secrets
if ([string]::IsNullOrWhiteSpace($env:HUBRELAY_TOKEN)) {
    $env:HUBRELAY_TOKEN = -join ((1..40) | ForEach-Object {
            'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'[(Get-Random -Maximum 62)]
        })
    Write-Host "Set session HUBRELAY_TOKEN ($($env:HUBRELAY_TOKEN.Length) chars)."
}

Write-Host '== In-process dry-run on fictional hosts =='
$job = New-HubJob -Playbook 'Get-ServiceHealth' -DryRun -Targets @('relay-alpha', 'relay-bravo')
Get-HubJobSummary -Id $job.Id | ConvertTo-Json -Depth 6

Write-Host '== Smoke test =='
Test-HubRelay | ConvertTo-Json -Depth 5

Write-Host '== Start listener (Simulation) =='
Start-HubRelay -Port 8765 -Simulation -PassThru | Format-List

try {
    $headers = @{ Authorization = "Bearer $($env:HUBRELAY_TOKEN)" }
    $health = Invoke-RestMethod -Uri 'http://127.0.0.1:8765/v1/health' -Headers $headers
    Write-Host "Health: $($health.status)"

    $body = Get-Content -Raw (Join-Path $PSScriptRoot 'sample-job.json')
    $created = Invoke-RestMethod -Uri 'http://127.0.0.1:8765/v1/jobs' -Headers $headers `
        -Method Post -ContentType 'application/json' -Body $body
    Write-Host "Created job $($created.Id) status=$($created.Status)"

    $summary = Invoke-RestMethod -Uri "http://127.0.0.1:8765/v1/jobs/$($created.Id)/summary" -Headers $headers
    $summary | ConvertTo-Json -Depth 6
}
finally {
    Stop-HubRelay
}

Write-Host 'Done.'
