# Purpose: InactiveUsers — General-purpose PowerShell utilities.
# powershell2
# get user accounts - calculate password changed last
# kerry

function Get-DomainUserAccounts
{

# Use Directory Services object to attach to the domain
$searcher = new-object DirectoryServices.DirectorySearcher([ADSI]"")
# Leaving the ADSI statement empty  - 108.45.123.69

# Filter down to User accounts
# (&(&(objectClass=user)(objectClass=organizationalPerson))(!(objectClass=computer))))
# $searcher.filter = "(&(objectClass=user))"
$searcher.filter = "(&(&(&(&(&(objectClass=user)(objectClass=organizationalPerson))(!(objectClass=computer))(!(ou:dn:=USERS))(!(ou:dn:=DisabledUsers))(!(ou:dn:=UtilityAccounts))))))"

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
# Property that contains the last password change in long integer format
$pwdlastset = $account.Properties["pwdlastset"];

# Convert the long integer to normal DateTime format
$lastchange = [datetime]::FromFileTimeUTC($pwdlastset[0]);

# Determine the timespan between the two dates
$datediff = new-TimeSpan $lastchange $(Get-Date);

# Create an output object for table formatting
$obj = new-Object PSObject;

# Add member properties with their name and value pair
$obj | Add-Member NoteProperty UserName($account.Properties["name"][0]);
$obj | Add-Member NoteProperty LastPasswordChange($lastchange);
$obj | Add-Member NoteProperty DaysSinceChange($datediff.Days);

# Write the output to the screen
Write-Output $obj;
}
}
}

Get-DomainUserAccounts | Where-Object {$_.DaysSinceChange -gt 60} | sort dayssincechange | Export-CSV H:\AD-Reports\user-inactive60days-AD.csv -NoType


#@@ #Poshboard Code
#$dash = new-pbdashboard -Name "Object Password Age Method" -MaxColumns 1
#$exclude = "UnixServer01","NetworkAppliance","Server01","Server02","Server03"
#add-pbitem $dash (import-csv c:\temp\AD.csv | where {$exclude -notcontains $_.ComputerName} | out-pbdatagrid ComputerName,DaysSinceChange,LastPasswordChange -name "Computer accounts older than 30 days" -fontsize 10 -showgrouppane 0)
#$dash
