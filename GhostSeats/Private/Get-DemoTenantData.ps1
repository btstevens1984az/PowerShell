function Get-DemoTenantData {
    [CmdletBinding()]
    param()

    $now = [datetime]::UtcNow

    $skuIds = @{
        SPE_E3              = 'c7df2760-2c81-4ef7-b578-5b5392b571df'
        SPE_E5              = '06ebc4ee-1bad-4000-9700-4bc91e292ead'
        POWER_BI_PRO        = 'f8a1db68-be16-40ed-86d5-cb42ce701560'
        VISIOCLIENT         = 'c52ea11f-cfc0-4cff-96e9-3bdbef8fcf0a'
        PROJECTPROFESSIONAL = '53818b1b-4a27-454b-8896-0dba576410e6'
        EMS                 = 'efccb6f7-5641-4e0e-bd10-b4976e1bf68e'
        O365_BUSINESS_PREMIUM = 'cbdc14ab-d96c-4c30-b9f4-6ada7cdc1d46'
    }

    function New-DemoUser {
        param(
            $DisplayName, $Upn, $Enabled, $UserType, $Department, $JobTitle,
            $Skus, $LastSignInDaysAgo
        )

        $licenses = foreach ($s in $Skus) {
            [pscustomobject]@{
                SkuPartNumber = $s
                SkuId         = $skuIds[$s]
            }
        }

        $last = $null
        if ($null -ne $LastSignInDaysAgo) {
            $last = $now.AddDays(-1 * [int]$LastSignInDaysAgo)
        }

        [pscustomobject]@{
            Id                 = [guid]::NewGuid().ToString()
            DisplayName        = $DisplayName
            UserPrincipalName  = $Upn
            AccountEnabled     = $Enabled
            UserType           = $UserType
            Department         = $Department
            JobTitle           = $JobTitle
            AssignedLicenses   = @($licenses)
            LastSignInDateTime = $last
        }
    }

    $users = @(
        (New-DemoUser 'Ava Nguyen' 'ava.nguyen@contoso.demo' $true 'Member' 'Engineering' 'Senior Engineer' @('SPE_E3') 2)
        (New-DemoUser 'Ben Carter' 'ben.carter@contoso.demo' $true 'Member' 'Finance' 'Controller' @('SPE_E5', 'POWER_BI_PRO') 5)
        (New-DemoUser 'Priya Shah' 'priya.shah@contoso.demo' $true 'Member' 'Marketing' 'Campaign Lead' @('SPE_E3') 12)
        (New-DemoUser 'Marcus Lee' 'marcus.lee@contoso.demo' $true 'Member' 'Sales' 'Account Exec' @('SPE_E3', 'VISIOCLIENT') 40)

        # Ghost seats — never signed in
        (New-DemoUser 'Temp Contractor' 'temp.contractor@contoso.demo' $true 'Member' 'Contractors' 'Contractor' @('SPE_E3') $null)
        (New-DemoUser 'Onboarding Seat' 'newhire.pending@contoso.demo' $true 'Member' 'HR' 'New Hire' @('SPE_E5', 'EMS') $null)
        (New-DemoUser 'Pilot User' 'pilot.user@contoso.demo' $true 'Member' 'IT' 'Pilot' @('O365_BUSINESS_PREMIUM') $null)

        # Ghost seats — inactive
        (New-DemoUser 'Jordan Miles' 'jordan.miles@contoso.demo' $true 'Member' 'Operations' 'Coordinator' @('SPE_E3') 128)
        (New-DemoUser 'Sam Ortiz' 'sam.ortiz@contoso.demo' $true 'Member' 'Support' 'Agent' @('SPE_E3', 'POWER_BI_PRO') 210)
        (New-DemoUser 'Riley Quinn' 'riley.quinn@contoso.demo' $true 'Member' 'Design' 'Designer' @('SPE_E5', 'VISIOCLIENT', 'PROJECTPROFESSIONAL') 95)
        (New-DemoUser 'Casey Brooks' 'casey.brooks@contoso.demo' $true 'Member' 'Sales' 'Rep' @('SPE_E3') 400)

        # Disabled but still licensed
        (New-DemoUser 'Alex Former' 'alex.former@contoso.demo' $false 'Member' 'Engineering' 'Ex-Engineer' @('SPE_E5', 'EMS') 60)
        (New-DemoUser 'Kim Alumni' 'kim.alumni@contoso.demo' $false 'Member' 'HR' 'Ex-HR' @('SPE_E3') 30)
        (New-DemoUser 'Pat Intern' 'pat.intern@contoso.demo' $false 'Member' 'Interns' 'Intern' @('O365_BUSINESS_PREMIUM', 'POWER_BI_PRO') 15)

        # Guest with license (waste)
        (New-DemoUser 'External Partner' 'partner@fabrikam.demo' $true 'Guest' 'Partners' 'Vendor' @('SPE_E3') 200)

        # Exclusions — should NOT appear as reclaim candidates by default
        (New-DemoUser 'Break Glass' 'breakglass@contoso.demo' $true 'Member' 'IT' 'Emergency Admin' @('SPE_E5') $null)
        (New-DemoUser 'Service Account' 'svc-backup@contoso.demo' $true 'Member' 'IT' 'Service' @('SPE_E3') $null)
        (New-DemoUser 'CEO Office' 'ceo@contoso.demo' $true 'Member' 'Executive' 'Chief Executive' @('SPE_E5') 180)
    )

    $subscribed = @(
        [pscustomobject]@{ SkuPartNumber = 'SPE_E3'; ConsumedUnits = 12; PrepaidUnits = [pscustomobject]@{ Enabled = 50 } }
        [pscustomobject]@{ SkuPartNumber = 'SPE_E5'; ConsumedUnits = 5; PrepaidUnits = [pscustomobject]@{ Enabled = 15 } }
        [pscustomobject]@{ SkuPartNumber = 'POWER_BI_PRO'; ConsumedUnits = 4; PrepaidUnits = [pscustomobject]@{ Enabled = 20 } }
        [pscustomobject]@{ SkuPartNumber = 'VISIOCLIENT'; ConsumedUnits = 2; PrepaidUnits = [pscustomobject]@{ Enabled = 10 } }
        [pscustomobject]@{ SkuPartNumber = 'PROJECTPROFESSIONAL'; ConsumedUnits = 1; PrepaidUnits = [pscustomobject]@{ Enabled = 5 } }
        [pscustomobject]@{ SkuPartNumber = 'EMS'; ConsumedUnits = 2; PrepaidUnits = [pscustomobject]@{ Enabled = 50 } }
        [pscustomobject]@{ SkuPartNumber = 'O365_BUSINESS_PREMIUM'; ConsumedUnits = 2; PrepaidUnits = [pscustomobject]@{ Enabled = 25 } }
    )

    return [pscustomobject]@{
        TenantName     = 'Contoso Demo (GhostSeats)'
        TenantId       = '11111111-2222-3333-4444-555555555555'
        Users          = $users
        SubscribedSkus = $subscribed
        GeneratedAtUtc = $now
    }
}
