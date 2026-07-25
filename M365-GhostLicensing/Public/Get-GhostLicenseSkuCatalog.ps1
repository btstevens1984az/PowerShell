function Get-GhostLicenseSkuCatalog {
    <#
    .SYNOPSIS
        Lists SKU part numbers with friendly names and estimated monthly USD prices.
    #>
    [CmdletBinding()]
    param()

    $config = Get-GhostLicensingConfigStore
    foreach ($name in ($config.SkuCatalog.PSObject.Properties.Name | Sort-Object)) {
        $entry = $config.SkuCatalog.$name
        [pscustomobject]@{
            SkuPartNumber = $name
            FriendlyName  = $entry.friendlyName
            MonthlyUsd    = [decimal]$entry.monthlyUsd
            Currency      = $config.Currency
        }
    }
}
