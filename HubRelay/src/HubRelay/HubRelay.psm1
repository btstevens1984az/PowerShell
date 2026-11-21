#Requires -Version 7.0
<#
.SYNOPSIS
    HubRelay — secure localhost control-plane for LLM tool calls.
.NOTES
    Author: HubRelay Contributors
    No telemetry. Tokens never logged.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:HubRelayState = [ordered]@{
    Listener          = $null
    Runspace          = $null
    PowerShell        = $null
    IsRunning         = $false
    Prefix            = $null
    TokenHash         = $null
    Simulation        = $false
    DryRunDefault     = $false
    RateLimitPerMinute = 60
    RequestTimestamps = [System.Collections.Generic.List[datetime]]::new()
    Jobs              = [System.Collections.Concurrent.ConcurrentDictionary[string, object]]::new()
    StartedAt         = $null
    RequestCount      = 0
    PlaybookRoot      = Join-Path $PSScriptRoot 'Playbooks'
    Allowlist         = @(
        'Clear-TempSafe'
        'Get-ServiceHealth'
    )
    # Fictional demo fleet only — never real inventory
    SimulatedFleet    = @(
        @{ Name = 'relay-alpha'; Role = 'edge'; Region = 'lab-west' }
        @{ Name = 'relay-bravo'; Role = 'worker'; Region = 'lab-east' }
        @{ Name = 'relay-charlie'; Role = 'worker'; Region = 'lab-central' }
    )
}

$privateDir = Join-Path $PSScriptRoot 'Private'
$publicDir  = Join-Path $PSScriptRoot 'Public'

Get-ChildItem -Path $privateDir -Filter '*.ps1' -ErrorAction Stop | ForEach-Object {
    . $_.FullName
}

Get-ChildItem -Path $publicDir -Filter '*.ps1' -ErrorAction Stop | ForEach-Object {
    . $_.FullName
}

Export-ModuleMember -Function @(
    'Start-HubRelay'
    'Stop-HubRelay'
    'New-HubJob'
    'Get-HubJob'
    'Get-HubJobSummary'
    'Test-HubRelay'
)
