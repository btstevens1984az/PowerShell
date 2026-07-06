# Purpose: Find-user — Active Directory user, group, and domain administration.
$rootdom = "LDAP://rootDSE"
$RootDomain = [System.DirectoryServices.DirectoryEntry] $rootdom
$defaultNC = $RootDomain.Get("defaultNamingContext")
$OrgContainer = "$defaultNC"

$OrgSearch = New-Object DirectoryServices.DirectorySearcher
$OrgSearch.SearchRoot = "LDAP://$OrgContainer" 
$OrgSearch.Filter = "(&(samaccountname=administrator))"
$OrgSearch.PageSize = 1000
$PropUBound = $OrgSearch.PropertiesToLoad.Add("distinguishedName") 

$PropUBound = $OrgSearch.PropertiesToLoad.Add("cn") 
$PropUBound = $OrgSearch.PropertiesToLoad.Add("legacyExchangeDN") 

$OrgDN = $OrgSearch.FindAll()
$OrgDN | %{$_.GetDirectoryEntry()}