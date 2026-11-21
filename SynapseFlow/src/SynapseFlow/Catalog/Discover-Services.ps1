function Discover-Services {
    <#
    .SYNOPSIS
        Catalog stage: discover services on a fictional target host.
    .NOTES
        Simulation-safe. Returns synthetic inventory only — no real machine probing.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Target,

        [switch]$Simulation
    )

    $mode = if ($Simulation) { 'Simulation' } else { 'Live' }

    # Fictional catalog responses only
    $servicesByHost = @{
        'web-01' = @('http', 'https', 'ssh')
        'web-02' = @('http', 'https')
        'db-01'  = @('postgres', 'ssh')
        'db-02'  = @('postgres', 'ssh', 'exporter')
        'app-01' = @('http', 'metrics', 'ssh')
    }

    $services = if ($servicesByHost.ContainsKey($Target)) {
        $servicesByHost[$Target]
    }
    else {
        @('ssh')
    }

    return [pscustomobject]@{
        Stage      = 'Discover-Services'
        Target     = $Target
        Mode       = $mode
        Services   = @($services)
        Discovered = $services.Count
        Timestamp  = [datetime]::UtcNow.ToString('o')
    }
}
