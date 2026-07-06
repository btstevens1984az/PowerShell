# Purpose: CreateOu — General-purpose PowerShell utilities.
# CreateOU.ps1
$adsi = [adsi]"LDAP://dc=nwtraders,dc=com"
$de = $adsi.create("OrganizationalUnit","ou=MyTestOu")
$de.SetInfo()