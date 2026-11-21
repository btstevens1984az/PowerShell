#Requires -Version 7.0
<#
.SYNOPSIS
    LegionPS — secure parallel playbook fan-out for PowerShell 7.
.NOTES
    Author: LegionPS Contributors
    No telemetry. Secrets are never committed; ephemeral HMAC keys live under the process temp LegionPS/ folder only.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:LegionModuleRoot = $PSScriptRoot
$script:LegionPlaybooksPath = Join-Path $PSScriptRoot 'Playbooks'
$script:LegionJobStore = [System.Collections.Concurrent.ConcurrentDictionary[string, object]]::new()
# Prefer GetTempPath so Linux hosts without $env:TEMP still work; keys stay ephemeral and uncommitted.
$script:LegionTempRoot = Join-Path ([System.IO.Path]::GetTempPath()) 'LegionPS'

if (-not (Test-Path -LiteralPath $script:LegionTempRoot)) {
    New-Item -ItemType Directory -Path $script:LegionTempRoot -Force | Out-Null
}

# Dot-source private helpers first, then public functions.
$privateDir = Join-Path $PSScriptRoot 'Private'
$publicDir = Join-Path $PSScriptRoot 'Public'

Get-ChildItem -LiteralPath $privateDir -Filter '*.ps1' -ErrorAction Stop |
    ForEach-Object { . $_.FullName }

Get-ChildItem -LiteralPath $publicDir -Filter '*.ps1' -ErrorAction Stop |
    ForEach-Object { . $_.FullName }

Export-ModuleMember -Function @(
    'Invoke-LegionJob'
    'New-LegionPlan'
    'Approve-LegionJob'
    'Get-LegionPlaybook'
    'Get-LegionJob'
    'Export-LegionSummary'
)
