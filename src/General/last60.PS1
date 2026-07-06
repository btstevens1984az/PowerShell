# Purpose: last60 — General-purpose PowerShell utilities.
$logondate = (get-date).adddays(-60).tofiletime()
$users = @()
([System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()).DomainControllers|select name | foreach {
    "Connecting to $($_.name)"
    $Root = New-Object directoryservices.directoryentry("LDAP://$($_.name)")
    $searcher = new-object System.DirectoryServices.DirectorySearcher($root)
    $searcher.Filter="(&(objectCategory=user)(lastlogon>=$logondate)(!(userAccountControl:1.2.840.113556.1.4.803:=2)))"
    #$searcher.PageSize = 500
    $searcher.PropertiesToLoad.AddRange(@("name","lastlogon"))
    $searcher.findall()|foreach {
        if ($users -notcontains $_.properties.name) {
            $users += $_.properties.name
        }
    }
}
$users.count