# Purpose: populatehash — General-purpose PowerShell utilities.
$prochash = @{}
#add all processes by name to hash table and increment for mulitple instances of the same process
Get-Process | %{$prochash.$($_.name) += 1}
#sort 
$prochash.GetEnumerator() | sort value -Descending

Import-Module ActiveDirectory
$hash = @{}
#Copy all AD users into the hashtable
get-aduser -Filter * -Properties * | %{$hash.$($_.name) = $_}
$hash.administrator.whencreated
$username = 'administrator'
if ($hash.$($username))
{
	"$Username already exists"
}