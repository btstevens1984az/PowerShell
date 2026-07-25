function Get-GhostSeatSkuCatalog {
    <#
    .SYNOPSIS
        Lists SKU part numbers with friendly names and estimated monthly USD prices.
    #>
    [CmdletBinding()]
    param()

    $config = Get-GhostSeatsConfigStore
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
