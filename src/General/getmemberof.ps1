# Purpose: getmemberof — General-purpose PowerShell utilities.
#only retrieve groups that are members of more than $numCount groups
$Numcount = 5
$OutGroups = @()
if (-not (Get-PSSnapin Quest.ActiveRoles.ADManagement -ErrorAction SilentlyContinue)) 
{
	Write-Host "Attempting to load Quest Active Roles cmdlets..."
	Add-PSSnapin Quest.ActiveRoles.ADManagement -ErrorAction stop
	Write-Host "Quest Active Roles cmdlets loaded successfully."
}
$groups = Get-QADGroup -GroupType "security" -PageSize 1000 -SizeLimit 0 
foreach ($group in $groups)
{
$memberof = $group| Get-QADMemberOf -Indirect
$count = $memberof.count
If ($count -gt $Numcount)
{
$group | Add-Member -MemberType noteproperty -name "memberofcount" -value $count
[array]$OutGroups = $OutGroups + $group
}
}
$OutGroups | Select-Object name,memberofcount | Sort memberofcount -Descending | Export-Csv "groups.csv" -NoTypeInformation