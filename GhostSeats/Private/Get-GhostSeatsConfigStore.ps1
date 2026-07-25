function Get-GhostSeatsConfigStore {
    [CmdletBinding()]
    param()

    if (-not $script:GhostSeatsConfig) {
        $catalogPath = Join-Path -Path $script:GhostSeatsRoot -ChildPath 'config/SkuCatalog.json'
        $catalog = Get-Content -LiteralPath $catalogPath -Raw -Encoding UTF8 | ConvertFrom-Json

        $script:GhostSeatsConfig = [pscustomobject]@{
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
            AuditLogPath            = (Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath 'GhostSeats-Audit.jsonl')
            DefaultReportPath       = (Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath 'GhostSeats-Reports')
        }
    }

    return $script:GhostSeatsConfig
}
