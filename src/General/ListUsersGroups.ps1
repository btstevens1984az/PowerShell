# Purpose: ListUsersGroups — General-purpose PowerShell utilities.
Get-QADUser -SizeLimit 0 | ForEach-Object{
$str = $_.Name
if($_.MemberOf){
	$_.MemberOf | ForEach-Object {$str += "`t" + (Get-QADGroup $_).Name }
}
	$str | Out-File "C:\PowershellReports\users-n-groups.txt" -Append
}