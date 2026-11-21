#Requires -Version 7.0
<#
.SYNOPSIS
    Lightweight Pester-compatible / standalone tests for SynapseFlow.
    Run: /tmp/pwsh-install/pwsh -File tests/SynapseFlow.Tests.ps1
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$moduleManifest = Join-Path $PSScriptRoot '..' 'src' 'SynapseFlow' 'SynapseFlow.psd1'
Import-Module $moduleManifest -Force

$script:Failed = 0
$script:Passed = 0

function Assert-True {
    param([bool]$Condition, [string]$Name)
    if ($Condition) {
        Write-Host "  PASS  $Name" -ForegroundColor Green
        $script:Passed++
    }
    else {
        Write-Host "  FAIL  $Name" -ForegroundColor Red
        $script:Failed++
    }
}

Write-Host 'SynapseFlow tests' -ForegroundColor Cyan

# --- Intent heuristic maps keywords to catalog stages ---
$plan = New-SynapsePlan -Intent 'discover services and verify health' -Targets @('web-01', 'db-02')
Assert-True ($plan.Stages.Count -ge 2) 'Intent plan has >= 2 stages'
Assert-True (@($plan.Stages.Name) -contains 'Discover-Services') 'Includes Discover-Services'
Assert-True (@($plan.Stages.Name) -contains 'Verify-Health') 'Includes Verify-Health'
Assert-True ($plan.Reviewed -eq $false) 'New plan is not Reviewed'
Assert-True ($plan.Status -eq 'Draft') 'New plan Status is Draft'

# --- Explicit stages from LLM ---
$explicit = New-SynapsePlan -Stages @(
    @{ Name = 'Discover-Services'; Targets = @('web-01') }
    @{ Name = 'Verify-Health'; DependsOn = @('stage-0'); Targets = @('web-01') }
) -Targets @('web-01')
Assert-True ($explicit.Stages.Count -eq 2) 'Explicit stages count = 2'
Assert-True ($explicit.Stages[1].DependsOn[0] -eq 'stage-0') 'DependsOn wired'

# --- Catalog allowlist rejection ---
$threw = $false
try {
    New-SynapsePlan -Stages @{ Name = 'Invoke-Expression' } | Out-Null
}
catch {
    $threw = $true
}
Assert-True $threw 'Rejects non-catalog stage name'

# --- Review gate for destructive stages ---
$destructivePlan = New-SynapsePlan -Intent 'restart spooler on web-01' -Targets @('web-01')
$needsApprove = $false
try {
    $destructivePlan | Confirm-SynapsePlan | Out-Null
}
catch {
    $needsApprove = $true
}
Assert-True $needsApprove 'Destructive plan requires -ApproveDestructive'

$reviewed = $destructivePlan | Confirm-SynapsePlan -ApproveDestructive
Assert-True ($reviewed.Reviewed -eq $true) 'Reviewed after approval'
Assert-True ($reviewed.DestructiveApproved -eq $true) 'DestructiveApproved set'

# --- Simulation run ---
$full = New-SynapsePlan -Intent 'discover, restart spooler, verify health' -Targets @('web-01', 'db-02')
$full = $full | Confirm-SynapsePlan -ApproveDestructive
$flow = Start-SynapseFlow -Plan $full -MaxParallelStages 2 -Simulation
Assert-True ($null -ne $flow.FlowId) 'Flow has FlowId'
Assert-True ($flow.Status -in @('Succeeded', 'Failed')) 'Flow completed'
Assert-True ($flow.Simulation -eq $true) 'Simulation flag set'

$fetched = Get-SynapseFlow -FlowId $flow.FlowId
Assert-True ($fetched.FlowId -eq $flow.FlowId) 'Get-SynapseFlow round-trip'

# --- Export redacts emails ---
$flow | Add-Member -NotePropertyName Note -NotePropertyValue 'contact ops@example.com please' -Force
$json = Export-SynapseReport -InputObject $flow
Assert-True ($json -match '\[REDACTED-EMAIL\]') 'Export redacts email'
Assert-True ($json -notmatch 'ops@example\.com') 'Raw email absent from report'

# --- Replan requires failures ---
$replanThrew = $false
try {
    if ($flow.Status -eq 'Succeeded') {
        # Force a synthetic failed flow for replan coverage
        $flow.Plan.Stages[-1].Status = 'Failed'
        $flow.Plan.Stages[-1].Error = 'Synthetic failure for test'
        $flow.Status = 'Failed'
    }
    $replanned = Repair-SynapseFlow -Flow $flow
    Assert-True ($replanned.Reviewed -eq $false) 'Replan returns Draft (not reviewed)'
    Assert-True ($replanned.Stages.Count -ge 1) 'Replan has stages'
}
catch {
    $replanThrew = $true
    Write-Host "  FAIL  Repair-SynapseFlow: $($_.Exception.Message)" -ForegroundColor Red
    $script:Failed++
}
if (-not $replanThrew) {
    # already asserted inside
}

Write-Host ""
Write-Host "Passed: $script:Passed  Failed: $script:Failed" -ForegroundColor $(if ($script:Failed -eq 0) { 'Green' } else { 'Red' })
if ($script:Failed -gt 0) { exit 1 }
exit 0
