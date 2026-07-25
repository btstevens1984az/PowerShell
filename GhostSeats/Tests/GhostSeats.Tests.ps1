#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

BeforeAll {
    $moduleManifest = Join-Path (Split-Path $PSScriptRoot -Parent) 'GhostSeats.psd1'
    Import-Module $moduleManifest -Force
}

Describe 'GhostSeats module' {
    It 'loads and exports expected commands' {
        $cmds = Get-Command -Module GhostSeats | Select-Object -ExpandProperty Name
        $cmds | Should -Contain 'Connect-GhostSeats'
        $cmds | Should -Contain 'Get-GhostSeat'
        $cmds | Should -Contain 'Invoke-GhostSeatAutomation'
        $cmds | Should -Contain 'Start-GhostSeatDemo'
    }

    Context 'Demo tenant' {
        BeforeAll {
            Connect-GhostSeats -Demo | Out-Null
        }

        AfterAll {
            Disconnect-GhostSeats
        }

        It 'connects in demo mode' {
            $cfg = Get-GhostSeatConfig
            $cfg.DemoMode | Should -BeTrue
            $cfg.Connected | Should -BeTrue
        }

        It 'finds ghost seats with cost estimates' {
            $seats = @(Get-GhostSeat)
            $seats.Count | Should -BeGreaterThan 5
            ($seats | Where-Object Category -eq 'DisabledAccount').Count | Should -BeGreaterThan 0
            ($seats | Where-Object Category -eq 'NeverSignedIn').Count | Should -BeGreaterThan 0
            ($seats | Where-Object Category -eq 'Inactive').Count | Should -BeGreaterThan 0
            ($seats | Measure-Object EstimatedMonthlyWasteUSD -Sum).Sum | Should -BeGreaterThan 0
        }

        It 'excludes break-glass and executive by default' {
            $seats = @(Get-GhostSeat)
            $seats.UserPrincipalName | Should -Not -Contain 'breakglass@contoso.demo'
            $seats.UserPrincipalName | Should -Not -Contain 'svc-backup@contoso.demo'
            $seats.UserPrincipalName | Should -Not -Contain 'ceo@contoso.demo'
        }

        It 'builds a summary' {
            $summary = Get-GhostSeatSummary
            $summary.GhostSeatCount | Should -BeGreaterThan 0
            $summary.EstimatedAnnualWasteUSD | Should -BeGreaterThan $summary.EstimatedMonthlyWasteUSD
        }

        It 'exports reports and approval list' {
            $out = Join-Path $TestDrive 'reports'
            $export = Export-GhostSeatReport -Path $out -Format Html, Csv, Json
            Test-Path $export.Paths.Html | Should -BeTrue
            Test-Path $export.Paths.Csv | Should -BeTrue
            Test-Path $export.Paths.Json | Should -BeTrue

            $approval = Join-Path $TestDrive 'approval.csv'
            New-GhostSeatApprovalList -Path $approval -PreApproveDisabledAccounts | Out-Null
            Test-Path $approval | Should -BeTrue
            $rows = Import-Csv $approval
            ($rows | Where-Object { $_.Approved -eq 'True' -and $_.Category -eq 'DisabledAccount' }).Count | Should -BeGreaterThan 0
        }

        It 'simulates reclaim in demo mode' {
            $approval = Join-Path $TestDrive 'reclaim.csv'
            New-GhostSeatApprovalList -Path $approval -PreApproveDisabledAccounts | Out-Null
            $results = @(Invoke-GhostSeatReclaim -ApprovalListPath $approval -Confirm:$false)
            $results.Count | Should -BeGreaterThan 0
            $results | ForEach-Object { $_.Status | Should -Be 'Simulated' }
            $results | ForEach-Object { $_.Mode | Should -Be 'Demo' }
        }

        It 'runs full automation' {
            $out = Join-Path $TestDrive 'auto'
            $result = Invoke-GhostSeatAutomation -OutputPath $out -AutoApproveDisabled
            $result.Summary.GhostSeatCount | Should -BeGreaterThan 0
            Test-Path $result.ApprovalList | Should -BeTrue
        }
    }

    It 'lists SKU catalog entries' {
        $skus = @(Get-GhostSeatSkuCatalog)
        $skus.Count | Should -BeGreaterThan 10
        $skus.SkuPartNumber | Should -Contain 'SPE_E3'
    }
}
