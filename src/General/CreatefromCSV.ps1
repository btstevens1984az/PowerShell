# Purpose: CreatefromCSV — General-purpose PowerShell utilities.
if (-not (Get-PSSnapin Quest.ActiveRoles.ADManagement -ErrorAction SilentlyContinue)) 
{
	Add-PSSnapin Quest.ActiveRoles.ADManagement -ErrorAction stop
}

$newusers = Import-Csv c:\temp\NewUsers.csv
$ou = "ou=test,dc=nwtraders,dc=com"
#Firstname,Lastname,EmployeeID,Department,Title
$newusers | ForEach-Object{
New-QADUser -Name ($_.firstname+$_.Lastname) -ParentContainer $ou `
-Department "dept" -Title "Dr" -FirstName ($_.firstname) -LastName ($_.lastname) `
-SamAccountName ($_.firstname+$_.Lastname) -ObjectAttributes @{employeeid=($_.employeeid)} `
-UserPrincipalName (($_.firstname+$_.Lastname)+"@114.13.196.208")| Enable-QADUser}
