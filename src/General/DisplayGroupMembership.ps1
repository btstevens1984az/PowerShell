# Purpose: DisplayGroupMembership — General-purpose PowerShell utilities.
﻿# -----------------------------------------------------------------------------
# DisplayGroupMembership.ps1
# ed wilson, msft, 10/9/2008
# 
# connects to a group, and retrieves the member property.
# uses [adsi] type accelerator to turn strngs into DirectoryEntry objects
#
# -----------------------------------------------------------------------------
$aryMembers = ([adsi]"LDAP://cn=mygroup,ou=mytest,dc=nwtraders,dc=com").member
foreach($member in $aryMembers)
{
 [adsi]"LDAP://$member" | 
 Select-Object -Property cn
}