function Restart-Spooler {
    <#
    .SYNOPSIS
        Catalog stage: restart print spooler on a fictional target (destructive).
    .NOTES
        Marked destructive. Simulation returns a planned action without side effects.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Target,

        [switch]$Simulation
    )

    $mode = if ($Simulation) { 'Simulation' } else { 'Live' }

    return [pscustomobject]@{
        Stage     = 'Restart-Spooler'
        Target    = $Target
        Mode      = $mode
        Action    = if ($Simulation) { 'WouldRestart' } else { 'Restarted' }
        Service   = 'Spooler'
        Destructive = $true
        Timestamp = [datetime]::UtcNow.ToString('o')
    }
}
