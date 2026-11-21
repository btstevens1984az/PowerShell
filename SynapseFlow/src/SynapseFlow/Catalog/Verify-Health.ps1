function Verify-Health {
    <#
    .SYNOPSIS
        Catalog stage: verify health signals on a fictional target host.
    .NOTES
        Simulation-safe. Returns synthetic health checks only.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Target,

        [switch]$Simulation
    )

    $mode = if ($Simulation) { 'Simulation' } else { 'Live' }

    $checks = @(
        [pscustomobject]@{ Name = 'reachability'; Status = 'Healthy' }
        [pscustomobject]@{ Name = 'disk';          Status = 'Healthy' }
        [pscustomobject]@{ Name = 'service-core'; Status = 'Healthy' }
    )

    return [pscustomobject]@{
        Stage     = 'Verify-Health'
        Target    = $Target
        Mode      = $mode
        Healthy   = $true
        Checks    = $checks
        Timestamp = [datetime]::UtcNow.ToString('o')
    }
}
