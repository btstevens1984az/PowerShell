function Get-GhostSeatConfig {
    <#
    .SYNOPSIS
        Gets the current GhostSeats configuration.
    #>
    [CmdletBinding()]
    param()

    Get-GhostSeatsConfigStore
}
