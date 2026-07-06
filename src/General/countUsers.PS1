# Purpose: countUsers — General-purpose PowerShell utilities.
$Root = New-Object DirectoryServices.DirectoryEntry $Dom

# Create a selector and start searching from the Root of AD
$selector = New-Object DirectoryServices.DirectorySearcher
$selector.SearchRoot = $root
# Filter the users with -like "CN=Person*". Note the ForEach loop
$adobj= $selector.findall() where {
$_.properties.objectcategory -like "CN=Person*"
}
foreach ($person in $adobj)
{
$prop=$person.properties
Write-host "First name: $($prop.givenname) Surname: $($prop.sn) User: $($prop.cn)"
}
Write-host "There are $($adobj.count) users in the $($root.name) domain" 