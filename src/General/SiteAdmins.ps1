# Purpose: SiteAdmins — General-purpose PowerShell utilities.
$sites = Get-SPOSite

$report2 = foreach ($site in $sites)
{
    $admins = (Get-spouser -site $site | where IsSiteAdmin -eq $true | select -ExpandProperty DisplayName) -join ';'
    
    [pscustomobject]@{
        "site" = $site.url
        "Admins" =$admins 

    }

}
#set additional admin
#Set-SPOUser -Site $mysite -LoginName $me.LoginName -IsSiteCollectionAdmin $true
