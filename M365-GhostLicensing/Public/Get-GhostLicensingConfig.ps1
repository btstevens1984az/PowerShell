function Get-GhostLicensingConfig {
    <#
    .SYNOPSIS
        Gets the current M365-GhostLicensing configuration.
    #>
    [CmdletBinding()]
    param()

    Get-GhostLicensingConfigStore
}
