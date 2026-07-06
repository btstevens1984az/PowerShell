# Purpose: CreateComputer — Windows desktop configuration and management.
# CreateComputer.ps1

$adsi = [adsi]"LDAP://ou=MyTestOU,dc=nwtraders,dc=com"
$de = $adsi.create("Computer","cn=MyComputer")
$de.SetInfo()