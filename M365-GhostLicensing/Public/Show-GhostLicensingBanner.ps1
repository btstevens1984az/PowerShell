function Show-GhostLicensingBanner {
    <#
    .SYNOPSIS
        Displays the M365-GhostLicensing console banner.
    #>
    [CmdletBinding()]
    param()

    $banner = @'

  ███╗   ███╗██████╗  ██████╗ ███████╗
  ████╗ ████║╚════██╗██╔════╝ ██╔════╝
  ██╔████╔██║ █████╔╝███████╗ ███████╗
  ██║╚██╔╝██║ ╚═══██╗██╔═══██╗╚════██║
  ██║ ╚═╝ ██║██████╔╝╚██████╔╝███████║
  ╚═╝     ╚═╝╚═════╝  ╚═════╝ ╚══════╝
       GhostLicensing

  Find unused Microsoft 365 licenses before they burn budget.
  Azure Entra authentication · Contoso demo · safe reclaim automation
'@

    Write-Host $banner -ForegroundColor Cyan
}
