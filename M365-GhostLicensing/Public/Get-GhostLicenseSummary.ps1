function Get-GhostLicenseSummary {
    <#
    .SYNOPSIS
        Summarizes ghost seat findings and estimated waste.
    .EXAMPLE
        Get-GhostLicenseSummary
        Get-GhostLicense | Get-GhostLicenseSummary
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [psobject]$InputObject,

        [ValidateRange(1, 3650)]
        [int]$InactiveDays
    )

    begin {
        $seats = New-Object System.Collections.Generic.List[object]
    }
    process {
        if ($PSBoundParameters.ContainsKey('InputObject') -and $null -ne $InputObject) {
            $seats.Add($InputObject)
        }
    }
    end {
        $config = Get-GhostLicensingConfigStore
        if ($seats.Count -eq 0) {
            $params = @{}
            if ($PSBoundParameters.ContainsKey('InactiveDays')) { $params.InactiveDays = $InactiveDays }
            foreach ($item in @(Get-GhostLicense @params)) {
                $seats.Add($item)
            }
        }

        $arr = @($seats.ToArray())
        $monthly = [math]::Round((($arr | Measure-Object EstimatedMonthlyWasteUSD -Sum).Sum), 2)
        $tenantName = if ($config.DemoMode) { 'Contoso Demo (M365-GhostLicensing)' } else { $config.TenantId }

        [pscustomobject]@{
            PSTypeName                 = 'M365.GhostLicensing.Summary'
            TenantName                 = $tenantName
            TenantId                   = $config.TenantId
            DemoMode                   = [bool]$config.DemoMode
            Source                     = $(if ($config.DemoMode) { 'Demo' } else { 'Graph' })
            InactiveDaysThreshold      = $(if ($PSBoundParameters.ContainsKey('InactiveDays')) { $InactiveDays } else { $config.InactiveDays })
            GhostLicenseCount             = $arr.Count
            DisabledAccountCount       = @($arr | Where-Object Category -eq 'DisabledAccount').Count
            NeverSignedInCount         = @($arr | Where-Object Category -eq 'NeverSignedIn').Count
            InactiveCount              = @($arr | Where-Object Category -eq 'Inactive').Count
            GuestWithLicenseCount      = @($arr | Where-Object Category -eq 'GuestWithLicense').Count
            EstimatedMonthlyWasteUSD   = $monthly
            EstimatedAnnualWasteUSD    = [math]::Round($monthly * 12, 2)
            TopWasteUpns               = @($arr | Select-Object -First 5 -ExpandProperty UserPrincipalName)
            GeneratedAtUtc             = [datetime]::UtcNow
        }
    }
}
