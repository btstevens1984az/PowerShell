# Purpose: ListOUChildren — General-purpose PowerShell utilities.
# -------------------------------------------------------
# ListOUChildren.ps1
# ed wilson, msft, 10/9/2008
#
#
# -------------------------------------------------------

([adsi]"LDAP://ou=mytest,dc=nwtraders,dc=com").children | 
Select-Object -Property cn