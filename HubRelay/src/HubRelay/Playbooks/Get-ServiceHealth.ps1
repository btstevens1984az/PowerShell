<#
.SYNOPSIS
    Reports simulated service health for a fictional fleet target.
.DESCRIPTION
    Allowlisted HubRelay playbook. Returns a structured health snapshot for
    demo/control-plane use. Does not probe real network inventory.
.PARAMETER Target
    Fictional host name (e.g. relay-bravo).
.PARAMETER ServiceName
    Logical service name to report on. Default: hubrelay-agent.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string] $Target,

    [string] $ServiceName = 'hubrelay-agent'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ($Target -match '[\\/]' -or $Target -match '\.\.') {
    throw "Invalid target name. Use a simple fictional hostname (e.g. relay-bravo)."
}

# Deterministic faux health from target name — offline-friendly, no telemetry
$hash = [Math]::Abs($Target.GetHashCode())
$status = if (($hash % 10) -eq 0) { 'Degraded' } else { 'Healthy' }
$cpu = 5 + ($hash % 40)
$mem = 20 + ($hash % 50)

return [pscustomobject]@{
    Target      = $Target
    Action      = 'Get-ServiceHealth'
    ServiceName = $ServiceName
    Status      = $status
    CpuPercent  = $cpu
    MemoryPercent = $mem
    CheckedAt   = [datetime]::UtcNow.ToString('o')
    Message     = "$ServiceName on $Target is $status."
}
