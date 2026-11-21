#!/usr/bin/env pwsh
#Requires -Version 7.0
<#
.SYNOPSIS
    Colorful LegionPS quickstart demo (offline Simulation).
.NOTES
    Uses fictional hosts only: web-01, db-02, app-03.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$modulePath = Join-Path $PSScriptRoot '..' 'src' 'LegionPS' 'LegionPS.psd1' | Resolve-Path
Import-Module $modulePath -Force

function Write-Banner {
    param([string]$Title)
    $esc = [char]27
    Write-Host ""
    Write-Host ("$esc[38;2;16;185;129m" + ('═' * 64) + "$esc[0m")
    Write-Host ("$esc[1;38;2;45;212;191m  LegionPS  $esc[0m$esc[38;2;167;243;208m· $Title$esc[0m")
    Write-Host ("$esc[38;2;16;185;129m" + ('═' * 64) + "$esc[0m")
}

Write-Banner 'Quickstart (Simulation)'

$esc = [char]27
Write-Host "$esc[38;2;52;211;153m▸ Listing allowlisted playbooks$esc[0m"
Get-LegionPlaybook | Format-Table Name, Synopsis -AutoSize

$targets = @('web-01', 'db-02', 'app-03')

Write-Host "$esc[38;2;52;211;153m▸ Building an LLM-friendly plan$esc[0m"
$plan = New-LegionPlan -Playbook Get-ServiceHealth -Targets $targets `
    -Rationale 'Pre-change health check on demo fleet' -Risk low
$plan | ConvertTo-Json -Depth 5 | Write-Host

Write-Host "$esc[38;2;52;211;153m▸ Dry-run fan-out$esc[0m"
$dry = Invoke-LegionJob -Playbook Get-ServiceHealth -Targets $targets -DryRun -Simulation
$dry.Results | Format-Table Target, Status, Output -AutoSize

Write-Host "$esc[38;2;52;211;153m▸ Gated job + approval$esc[0m"
$gated = Invoke-LegionJob -Playbook Restart-Spooler -Targets 'web-01', 'app-03' `
    -ApprovalMode Required -Simulation -UseHmac
Write-Host "Pending job: $($gated.JobId) status=$($gated.Status)"
Approve-LegionJob -JobId $gated.JobId -Approver 'ops-lead' -Comment 'Demo approval' | Out-Null
$done = Invoke-LegionJob -JobId $gated.JobId -Simulation
$done.Results | Format-Table Target, Status -AutoSize

Write-Host "$esc[38;2;52;211;153m▸ Redacted export$esc[0m"
$summary = Export-LegionSummary -JobId $done.JobId -PassThru
Write-Host $summary

Write-Banner 'Done — no live remoting was used'
