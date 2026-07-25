function Get-GhostLicenseUserInventory {
    [CmdletBinding()]
    param()

    $config = Get-GhostLicensingConfigStore

    if ($config.DemoMode) {
        $demo = Get-DemoTenantData
        return $demo.Users
    }

    if (-not $config.Connected) {
        throw "Not connected. Run Connect-GhostLicensing (or Connect-GhostLicensing -Demo) first."
    }

    $hasMgUser = Get-Command -Name Get-MgUser -ErrorAction SilentlyContinue
    if (-not $hasMgUser) {
        throw "Microsoft.Graph.Users is required for live mode. Install-Module Microsoft.Graph.Users -Scope CurrentUser"
    }

    Write-Verbose "Querying Microsoft Graph for licensed users..."

    $properties = @(
        'Id', 'DisplayName', 'UserPrincipalName', 'AccountEnabled', 'UserType',
        'Department', 'JobTitle', 'AssignedLicenses', 'SignInActivity'
    )

    try {
        $users = Get-MgUser -All -Property $properties -PageSize 100 -ErrorAction Stop
    }
    catch {
        throw "Failed to query users from Microsoft Graph: $($_.Exception.Message)"
    }

    $skuMap = @{}
    if (Get-Command Get-MgSubscribedSku -ErrorAction SilentlyContinue) {
        foreach ($sku in (Get-MgSubscribedSku -All -ErrorAction SilentlyContinue)) {
            $skuMap[$sku.SkuId] = $sku.SkuPartNumber
        }
    }

    foreach ($u in $users) {
        if (-not $u.AssignedLicenses -or $u.AssignedLicenses.Count -eq 0) { continue }

        $licenses = foreach ($al in $u.AssignedLicenses) {
            $part = if ($skuMap.ContainsKey($al.SkuId)) { $skuMap[$al.SkuId] } else { [string]$al.SkuId }
            [pscustomobject]@{
                SkuId         = $al.SkuId
                SkuPartNumber = $part
            }
        }

        $last = $null
        if ($u.SignInActivity) {
            if ($u.SignInActivity.LastSuccessfulSignInDateTime) {
                $last = [datetime]$u.SignInActivity.LastSuccessfulSignInDateTime
            }
            elseif ($u.SignInActivity.LastSignInDateTime) {
                $last = [datetime]$u.SignInActivity.LastSignInDateTime
            }
        }

        [pscustomobject]@{
            Id                 = $u.Id
            DisplayName        = $u.DisplayName
            UserPrincipalName  = $u.UserPrincipalName
            AccountEnabled     = $u.AccountEnabled
            UserType           = $u.UserType
            Department         = $u.Department
            JobTitle           = $u.JobTitle
            AssignedLicenses   = @($licenses)
            LastSignInDateTime = $last
        }
    }
}
