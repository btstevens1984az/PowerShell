function Resolve-SkuInfo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$SkuPartNumber
    )

    $config = Get-GhostLicensingConfigStore
    $key = $SkuPartNumber
    $entry = $null

    if ($config.SkuCatalog.PSObject.Properties.Name -contains $key) {
        $entry = $config.SkuCatalog.$key
    }

    if ($entry) {
        return [pscustomobject]@{
            SkuPartNumber = $SkuPartNumber
            FriendlyName  = $entry.friendlyName
            MonthlyUsd    = [decimal]$entry.monthlyUsd
        }
    }

    return [pscustomobject]@{
        SkuPartNumber = $SkuPartNumber
        FriendlyName  = $SkuPartNumber
        MonthlyUsd    = [decimal]0
    }
}
