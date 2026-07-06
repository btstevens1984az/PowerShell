# Purpose: UpdateUsersCheckFirst — General-purpose PowerShell utilities.
#if (-not (Get-PSSnapin Quest.ActiveRoles.ADManagement -ErrorAction SilentlyContinue)) 
#{
#	Add-PSSnapin Quest.ActiveRoles.ADManagement -ErrorAction stop
#}

$users = Get-QADGroupMember testusers -ldapFilter "(&(objectcategory=person)(objectclass=user))" -indirect 


foreach ($user in $users)
{
	if($user.department -eq "NotIT")
	{
	 	$user | Set-qaduser -department "IT"
	}
 
}