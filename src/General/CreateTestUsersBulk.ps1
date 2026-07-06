# Purpose: CreateTestUsersBulk — General-purpose PowerShell utilities.
#create test users
if (-not (Get-PSSnapin Quest.ActiveRoles.ADManagement -ErrorAction SilentlyContinue)) 
{
	Add-PSSnapin Quest.ActiveRoles.ADManagement -ErrorAction stop
}

$numUsers = 10
$parentContainer = "OU=test,dc=nwtraders,dc=com"
$password = "Password1"
$userPrefix = "testuser"
Write-Verbose "creating test users:"
for ($i=1;$i -le $numUsers;$i++)
{
	Write-Debug "creating test user:$userPrefix$i"
	(New-QADUser -name "$userPrefix$i" -ParentContainer $parentContainer -UserPassword $password)
}