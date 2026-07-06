# Purpose: DirectorySearcherComputer — Windows desktop configuration and management.
$rootdom = "LDAP://rootDSE"
$RootDomain = [System.DirectoryServices.DirectoryEntry] $rootdom
$defaultNC = $RootDomain.Get("defaultNamingContext")
$OrgContainer = "$defaultNC"

$OrgSearch = New-Object DirectoryServices.DirectorySearcher
$OrgSearch.SearchRoot = "LDAP://$OrgContainer" 
$OrgSearch.Filter = "(&(objectCategory=computer))"
$OrgSearch.PageSize = 1000
$OrgSearch.PropertiesToLoad.Add("distinguishedName")
$OrgSearch.PropertiesToLoad.Add("cn")
$OrgSearch.PropertiesToLoad.Add("name")

$OrgDN = $OrgSearch.FindAll()
$OrgDN | format-list
$computernames = $OrgDN.Properties.name