# Purpose: CreateUser — General-purpose PowerShell utilities.
# CreateUser.ps1

$adsi = [adsi]"LDAP://ou=MyTestOU,dc=nwtraders,dc=com"
$de = $adsi.create("User","cn=MyUser")
$de.SetInfo()