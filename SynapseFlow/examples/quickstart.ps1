#Requires -Version 7.0
<#
.SYNOPSIS
    SynapseFlow quickstart — fictional hosts only (web-01, db-02).
#>

$ErrorActionPreference = 'Stop'

$moduleRoot = Join-Path $PSScriptRoot '..' 'src' 'SynapseFlow'
Import-Module (Join-Path $moduleRoot 'SynapseFlow.psd1') -Force

Write-Host '=== New-SynapsePlan (intent heuristic) ===' -ForegroundColor Cyan
$plan = New-SynapsePlan -Intent 'discover services, restart spooler, then verify health' -Targets @('web-01', 'db-02')
$plan | ConvertTo-Json -Depth 6 | Write-Host

Write-Host '=== Confirm-SynapsePlan (approve destructive) ===' -ForegroundColor Cyan
$reviewed = $plan | Confirm-SynapsePlan -ApproveDestructive
Write-Host "Reviewed=$($reviewed.Reviewed) Status=$($reviewed.Status)"

Write-Host '=== Start-SynapseFlow (Simulation) ===' -ForegroundColor Cyan
$flow = Start-SynapseFlow -Plan $reviewed -MaxParallelStages 2 -Simulation
Write-Host "FlowId=$($flow.FlowId) Status=$($flow.Status)"

Write-Host '=== Get-SynapseFlow ===' -ForegroundColor Cyan
Get-SynapseFlow -FlowId $flow.FlowId | Select-Object FlowId, Status, Simulation | Format-List

Write-Host '=== Export-SynapseReport ===' -ForegroundColor Cyan
$reportPath = Join-Path $PSScriptRoot 'sample-report.json'
Export-SynapseReport -InputObject $flow -Path $reportPath | Out-Null
Write-Host "Wrote redacted report: $reportPath"

Write-Host 'Done.' -ForegroundColor Green
