# Purpose: CreateGroup — General-purpose PowerShell utilities.
# CreateGroup.ps1

$adsi = [adsi]"LDAP://ou=MyTestOU,dc=nwtraders,dc=com"
$de = $adsi.create("Group","cn=MyGroup")
$de.SetInfo()