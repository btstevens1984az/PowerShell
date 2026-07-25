#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

BeforeAll {
    $moduleManifest = Join-Path (Split-Path $PSScriptRoot -Parent) 'M365-GhostLicensing.psd1'
    Import-Module $moduleManifest -Force
}

Describe 'M365-GhostLicensing module' {
    It 'loads and exports expected commands' {
        $cmds = Get-Command -Module M365-GhostLicensing | Select-Object -ExpandProperty Name
        $cmds | Should -Contain 'Connect-GhostLicensing'
        $cmds | Should -Contain 'Get-GhostLicense'
        $cmds | Should -Contain 'Invoke-GhostLicenseAutomation'
        $cmds | Should -Contain 'Start-GhostLicensingDemo'
    }

    Context 'Demo tenant' {
        BeforeAll {
            Connect-GhostLicensing -Demo | Out-Null
        }

        AfterAll {
            Disconnect-GhostLicensing
        }

        It 'connects in demo mode' {
            $cfg = Get-GhostLicensingConfig
            $cfg.DemoMode | Should -BeTrue
            $cfg.Connected | Should -BeTrue
            $cfg.AuthMethod | Should -Be 'Demo'
        }

        It 'finds ghost licenses with cost estimates' {
            $seats = @(Get-GhostLicense)
            $seats.Count | Should -BeGreaterThan 5
            ($seats | Where-Object Category -eq 'DisabledAccount').Count | Should -BeGreaterThan 0
            ($seats | Where-Object Category -eq 'NeverSignedIn').Count | Should -BeGreaterThan 0
            ($seats | Where-Object Category -eq 'Inactive').Count | Should -BeGreaterThan 0
            ($seats | Measure-Object EstimatedMonthlyWasteUSD -Sum).Sum | Should -BeGreaterThan 0
        }

        It 'excludes break-glass and executive by default' {
            $seats = @(Get-GhostLicense)
            $seats.UserPrincipalName | Should -Not -Contain 'breakglass@contoso.demo'
            $seats.UserPrincipalName | Should -Not -Contain 'svc-backup@contoso.demo'
            $seats.UserPrincipalName | Should -Not -Contain 'ceo@contoso.demo'
        }

        It 'builds a summary' {
            $summary = Get-GhostLicenseSummary
            $summary.GhostLicenseCount | Should -BeGreaterThan 0
            $summary.EstimatedAnnualWasteUSD | Should -BeGreaterThan $summary.EstimatedMonthlyWasteUSD
        }

        It 'exports reports and approval list' {
            $out = Join-Path $TestDrive 'reports'
            $export = Export-GhostLicenseReport -Path $out -Format Html, Csv, Json
            Test-Path $export.Paths.Html | Should -BeTrue
            Test-Path $export.Paths.Csv | Should -BeTrue
            Test-Path $export.Paths.Json | Should -BeTrue

            $approval = Join-Path $TestDrive 'approval.csv'
            New-GhostLicenseApprovalList -Path $approval -PreApproveDisabledAccounts | Out-Null
            Test-Path $approval | Should -BeTrue
            $rows = Import-Csv $approval
            ($rows | Where-Object { $_.Approved -eq 'True' -and $_.Category -eq 'DisabledAccount' }).Count | Should -BeGreaterThan 0
        }

        It 'simulates reclaim in demo mode' {
            $approval = Join-Path $TestDrive 'reclaim.csv'
            New-GhostLicenseApprovalList -Path $approval -PreApproveDisabledAccounts | Out-Null
            $results = @(Invoke-GhostLicenseReclaim -ApprovalListPath $approval -Confirm:$false)
            $results.Count | Should -BeGreaterThan 0
            $results | ForEach-Object { $_.Status | Should -Be 'Simulated' }
            $results | ForEach-Object { $_.Mode | Should -Be 'Demo' }
        }

        It 'runs full automation' {
            $out = Join-Path $TestDrive 'auto'
            $result = Invoke-GhostLicenseAutomation -OutputPath $out -AutoApproveDisabled
            $result.Summary.GhostLicenseCount | Should -BeGreaterThan 0
            Test-Path $result.ApprovalList | Should -BeTrue
        }
    }

    It 'lists SKU catalog entries' {
        $skus = @(Get-GhostLicenseSkuCatalog)
        $skus.Count | Should -BeGreaterThan 10
        $skus.SkuPartNumber | Should -Contain 'SPE_E3'
    }
}
