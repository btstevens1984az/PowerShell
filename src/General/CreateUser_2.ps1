# Purpose: CreateUser 2 — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE:
#
# KEYWORDS: ADSI, Abstract, Pattern
#
# COMMENTS: This script creates an object in AD
# Can create a user, comptuer, group, organizationalUnit
# and other objects in AD. In many cases, you will normally
# be connecting to the same location in AD. You can therefore use a 
# constant value for the path if you wish.
#
# ------------------------------------------------------------------------

New-Variable -name path -value "dc=nwtraders,dc=com" -option constant
$class = "user"
$name = "cn=myuser,ou=testou"

$adsi = [adsi]"LDAP://$path"
$de = $adsi.Create($class,$name)
$de.SetInfo()