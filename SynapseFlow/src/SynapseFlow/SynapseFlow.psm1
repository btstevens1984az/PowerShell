#Requires -Version 7.0
<#
.SYNOPSIS
    SynapseFlow — intent-driven DAG orchestration for PowerShell 7.
.NOTES
    Author: SynapseFlow Contributors
    No telemetry. Catalog allowlist only.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# In-memory flow registry (session-scoped; no persistence / no telemetry)
$script:SynapseFlowRegistry = [System.Collections.Concurrent.ConcurrentDictionary[string, object]]::new()

$privateDir = Join-Path $PSScriptRoot 'Private'
$publicDir  = Join-Path $PSScriptRoot 'Public'
$catalogDir = Join-Path $PSScriptRoot 'Catalog'

foreach ($file in Get-ChildItem -Path $privateDir -Filter '*.ps1' -ErrorAction Stop) {
    . $file.FullName
}

foreach ($file in Get-ChildItem -Path $publicDir -Filter '*.ps1' -ErrorAction Stop) {
    . $file.FullName
}

# Catalog scripts are dot-sourced so Invoke-StageParallel can call them by name
foreach ($file in Get-ChildItem -Path $catalogDir -Filter '*.ps1' -ErrorAction Stop) {
    . $file.FullName
}

Export-ModuleMember -Function @(
    'New-SynapsePlan'
    'Confirm-SynapsePlan'
    'Start-SynapseFlow'
    'Get-SynapseFlow'
    'Repair-SynapseFlow'
    'Export-SynapseReport'
)
