# Purpose: DirectorySearcher — General-purpose PowerShell utilities.
$rootdom = "LDAP://rootDSE"
$RootDomain = [System.DirectoryServices.DirectoryEntry] $rootdom
$defaultNC = $RootDomain.Get("defaultNamingContext")
$OrgContainer = "$defaultNC"

$OrgSearch = New-Object DirectoryServices.DirectorySearcher
$OrgSearch.SearchRoot = "LDAP://$OrgContainer" 
$OrgSearch.Filter = "(&(objectCategory=user))"
$OrgSearch.PageSize = 1000
$OrgSearch.PropertiesToLoad.Add("distinguishedName")
$OrgSearch.PropertiesToLoad.Add("cn")

$OrgDN = $OrgSearch.FindAll()
$OrgDN | format-list