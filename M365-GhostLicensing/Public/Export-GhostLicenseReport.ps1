function Export-GhostLicenseReport {
    <#
    .SYNOPSIS
        Exports ghost seat findings to HTML, CSV, and/or JSON.
    .PARAMETER Path
        Output directory or base file path (extension optional).
    .PARAMETER Format
        One or more of Html, Csv, Json. Default: all three.
    .PARAMETER Open
        Open the HTML report after export.
    .EXAMPLE
        Export-GhostLicenseReport -Path ./reports -Open
    #>
    [CmdletBinding()]
    [Alias('eglr')]
    param(
        [Parameter(ValueFromPipeline)]
        [psobject]$InputObject,

        [string]$Path,

        [ValidateSet('Html', 'Csv', 'Json')]
        [string[]]$Format = @('Html', 'Csv', 'Json'),

        [switch]$Open,

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
        $summary = $arr | Get-GhostLicenseSummary

        if (-not $Path) {
            $Path = Join-Path $config.DefaultReportPath ("M365-GhostLicensing-{0:yyyyMMdd-HHmmss}" -f [datetime]::UtcNow)
        }

        $baseDir = $Path
        $baseName = 'GhostLicense-Report'
        if ($Path -match '\.(html?|csv|json)$') {
            $baseDir = Split-Path -Parent $Path
            $baseName = [System.IO.Path]::GetFileNameWithoutExtension($Path)
        }

        if (-not (Test-Path -LiteralPath $baseDir)) {
            New-Item -ItemType Directory -Path $baseDir -Force | Out-Null
        }

        $outputs = [ordered]@{}

        if ('Csv' -in $Format) {
            $csvPath = Join-Path $baseDir "$baseName.csv"
            $arr | Select-Object DisplayName, UserPrincipalName, Category, InactiveDays, AccountEnabled, UserType,
                Department, LicenseSummary, EstimatedMonthlyWasteUSD, EstimatedAnnualWasteUSD, LastSignInDateTime,
                RecommendedAction, Reason |
                Export-Csv -LiteralPath $csvPath -NoTypeInformation -Encoding UTF8
            $outputs.Csv = $csvPath
        }

        if ('Json' -in $Format) {
            $jsonPath = Join-Path $baseDir "$baseName.json"
            [pscustomobject]@{
                summary = $summary
                seats   = $arr
            } | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $jsonPath -Encoding UTF8
            $outputs.Json = $jsonPath
        }

        if ('Html' -in $Format) {
            $htmlPath = Join-Path $baseDir "$baseName.html"
            New-GhostLicenseHtmlReport -Seats $arr -Summary $summary -Path $htmlPath | Out-Null
            $outputs.Html = $htmlPath
            if ($Open) {
                Invoke-Item -LiteralPath $htmlPath
            }
        }

        Write-GhostLicensingAudit -Action 'Export-GhostLicenseReport' -Data @{ outputs = $outputs; count = $arr.Count }

        [pscustomobject]@{
            Summary = $summary
            Paths   = [pscustomobject]$outputs
            Count   = $arr.Count
        }
    }
}
