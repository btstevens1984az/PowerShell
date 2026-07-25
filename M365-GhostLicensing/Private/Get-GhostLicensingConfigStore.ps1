function Get-GhostLicensingConfigStore {
    [CmdletBinding()]
    param()

    if (-not $script:GhostLicensingConfig) {
        $catalogPath = Join-Path -Path $script:GhostLicensingRoot -ChildPath 'config/SkuCatalog.json'
        $catalog = Get-Content -LiteralPath $catalogPath -Raw -Encoding UTF8 | ConvertFrom-Json

        $script:GhostLicensingConfig = [pscustomobject]@{
            InactiveDays            = 90
            IncludeGuests           = $false
            ExcludeUpnPatterns      = @('breakglass*', 'emergency*', 'admin@*', '*-sa@*', 'svc-*@*')
            ExcludeDepartments      = @('Executive', 'Legal')
            MinimumMonthlyWasteUSD  = 0
            Currency                = $catalog.currency
            SkuCatalog              = $catalog.skus
            DemoMode                = $false
            Connected               = $false
            TenantId                = $null
            AuthMethod              = $null
            AuditLogPath            = (Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath 'M365-GhostLicensing-Audit.jsonl')
            DefaultReportPath       = (Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath 'M365-GhostLicensing-Reports')
        }
    }

    return $script:GhostLicensingConfig
}
