# Purpose: GetNestedUsersFromGroup — General-purpose PowerShell utilities.
Get-QADGroupMember testusers -ldapFilter "(&(objectcategory=person)(objectclass=user))" -indirect