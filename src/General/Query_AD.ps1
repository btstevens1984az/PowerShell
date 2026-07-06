# Purpose: Query AD — General-purpose PowerShell utilities.
$strFilter = "(&(objectCategory=computer)(name=mgh*))"

$objDomain = New-Object System.DirectoryServices.DirectoryEntry

$objSearcher = New-Object System.DirectoryServices.DirectorySearcher("LDAP://OU=regional_sites,dc=chw,dc=edu")
$objSearcher.SearchRoot = $objDomain
$objSearcher.PageSize = 1000
$objSearcher.Filter = $strFilter
$objSearcher.SearchScope = "Subtree"

$colProplist = "name"
foreach ($i in $colPropList){$objSearcher.PropertiesToLoad.Add($i)}

$colResults = $objSearcher.FindAll()

foreach ($objResult in $colResults)
    {$objItem = $objResult.Properties; $objItem.name}

