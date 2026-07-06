# Purpose: GroupInventory — System monitoring and alerting.
# powershell2
# get user accounts - calculate password changed last
# kerry

#get-qaduser -includeallproperties -sizelimit 20 | select-object logonname, email
Get-QADGroup -sizelimit 0 | Export-Csv "H:\AD-Reports\AD_GroupsInventoryName.csv"

function Get-TheGroups
{

# Use Directory Services object to attach to the domain
$searcher = new-object DirectoryServices.DirectorySearcher([ADSI]"")
# Leaving the ADSI statement empty  - 108.45.123.69

# Filter down to User accounts
# (&(&(objectClass=user)(objectClass=organizationalPerson))(!(objectClass=computer))))


$searcher.filter = "(&(objectClass=group))"
# $searcher.filter = "(&(&(&(&(&(objectClass=user)(objectClass=organizationalPerson))(!(objectClass=computer))(!(ou:dn:=USERS))(!(ou:dn:=DisabledUsers))(!(ou:dn:=UtilityAccounts))))))"

# Cache the results
$searcher.CacheResults = $true
$searcher.SearchScope = �Subtree�
$searcher.PageSize = 1000

# Find anything you can that matches the definition of being a user object
$accounts = $searcher.FindAll()

# Check to make sure we found some accounts
if($accounts.Count -gt 0)
{
foreach($account in $accounts)
	{
# 
#$ADGroupName = $account.Properties["GroupName"];

# Determine the timespan between the two dates
# $datediff = new-TimeSpan $lastchange $(Get-Date);

# Create an output object for table formatting
$obj = new-Object PSObject;

# Add member properties with their name and value pair
$obj | Add-Member NoteProperty GroupName($account.Properties["GroupName"][0]);
$obj | Add-Member NoteProperty GroupType($account.Properties["GroupType"][0]);
$obj | Add-Member NoteProperty GroupScope($account.Properties["GroupScope"][0]);
$obj | Add-Member NoteProperty DistinguishedName($account.Properties["DN"][0]);
$obj | Add-Member NoteProperty Description($account.Properties["Discription"][0]);
# Write the output to the screen
Write-Output $obj;
}
}
}

Get-TheGroups | Export-CSV H:\AD-Reports\AD_GroupAudit.csv

