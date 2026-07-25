function Set-GhostSeatConfig {
    <#
    .SYNOPSIS
        Updates GhostSeats configuration for the current session.
    .PARAMETER InactiveDays
        Number of days without sign-in before a licensed user is considered inactive.
    .PARAMETER IncludeGuests
        Include guest users in analysis.
    .PARAMETER ExcludeUpnPatterns
        Wildcard UPN patterns to exclude (break-glass, service accounts, etc.).
    .PARAMETER ExcludeDepartments
        Department names to exclude from reclaim candidates.
    .PARAMETER PriceTablePath
        Path to a JSON file overriding SKU friendly names / monthly USD prices.
    .PARAMETER AuditLogPath
        Path to the JSONL audit log.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [ValidateRange(1, 3650)]
        [int]$InactiveDays,

        [bool]$IncludeGuests,

        [string[]]$ExcludeUpnPatterns,

        [string[]]$ExcludeDepartments,

        [ValidateScript({ Test-Path -LiteralPath $_ })]
        [string]$PriceTablePath,

        [string]$AuditLogPath,

        [ValidateRange(0, 100000)]
        [decimal]$MinimumMonthlyWasteUSD
    )

    $config = Get-GhostSeatsConfigStore

    if ($PSCmdlet.ShouldProcess('GhostSeats configuration', 'Update')) {
        if ($PSBoundParameters.ContainsKey('InactiveDays')) { $config.InactiveDays = $InactiveDays }
        if ($PSBoundParameters.ContainsKey('IncludeGuests')) { $config.IncludeGuests = $IncludeGuests }
        if ($PSBoundParameters.ContainsKey('ExcludeUpnPatterns')) { $config.ExcludeUpnPatterns = $ExcludeUpnPatterns }
        if ($PSBoundParameters.ContainsKey('ExcludeDepartments')) { $config.ExcludeDepartments = $ExcludeDepartments }
        if ($PSBoundParameters.ContainsKey('AuditLogPath')) { $config.AuditLogPath = $AuditLogPath }
        if ($PSBoundParameters.ContainsKey('MinimumMonthlyWasteUSD')) { $config.MinimumMonthlyWasteUSD = $MinimumMonthlyWasteUSD }

        if ($PriceTablePath) {
            $json = Get-Content -LiteralPath $PriceTablePath -Raw -Encoding UTF8 | ConvertFrom-Json
            if ($json.skus) {
                $config.SkuCatalog = $json.skus
                if ($json.currency) { $config.Currency = $json.currency }
            }
            else {
                $config.SkuCatalog = $json
            }
        }

        Write-GhostSeatAudit -Action 'Set-GhostSeatConfig' -Data @{
            InactiveDays = $config.InactiveDays
            IncludeGuests = $config.IncludeGuests
        }
    }

    return $config
}
