# Purpose: CreateUser 1 — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE:
#
# KEYWORDS: ADSI, Abstract, Pattern
#
# COMMENTS: This script creates an object in AD
# Can create a user, comptuer, group, organizationalUnit
# and other objects in AD. 
#
#
# ------------------------------------------------------------------------

$path = "dc=nwtraders,dc=com"
$class = "user"
$name = "cn=myuser,ou=testou"

$adsi = [adsi]"LDAP://$path"
$de = $adsi.Create($class,$name)
$de.SetInfo()