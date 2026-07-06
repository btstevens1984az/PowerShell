# Purpose: CreateContact — General-purpose PowerShell utilities.
# CreateContact.ps1

$adsi = [adsi]"LDAP://ou=MyTestOU,dc=nwtraders,dc=com"
$de = $adsi.create("Contact","cn=MyContact")
$de.SetInfo()