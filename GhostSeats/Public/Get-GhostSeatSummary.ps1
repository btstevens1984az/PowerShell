function Get-GhostSeatSummary {
    <#
    .SYNOPSIS
        Summarizes ghost seat findings and estimated waste.
    .EXAMPLE
        Get-GhostSeatSummary
        Get-GhostSeat | Get-GhostSeatSummary
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
        $config = Get-GhostSeatsConfigStore
        if ($seats.Count -eq 0) {
            $params = @{}
            if ($PSBoundParameters.ContainsKey('InactiveDays')) { $params.InactiveDays = $InactiveDays }
            foreach ($item in @(Get-GhostSeat @params)) {
                $seats.Add($item)
            }
        }

        $arr = @($seats.ToArray())
        $monthly = [math]::Round((($arr | Measure-Object EstimatedMonthlyWasteUSD -Sum).Sum), 2)
        $tenantName = if ($config.DemoMode) { 'Contoso Demo (GhostSeats)' } else { $config.TenantId }

        [pscustomobject]@{
            PSTypeName                 = 'GhostSeats.Summary'
            TenantName                 = $tenantName
            TenantId                   = $config.TenantId
            DemoMode                   = [bool]$config.DemoMode
            Source                     = $(if ($config.DemoMode) { 'Demo' } else { 'Graph' })
            InactiveDaysThreshold      = $(if ($PSBoundParameters.ContainsKey('InactiveDays')) { $InactiveDays } else { $config.InactiveDays })
            GhostSeatCount             = $arr.Count
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
