# Purpose: CreateObject Param — General-purpose PowerShell utilities.
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

Param(
      $path = "dc=nwtraders,dc=com",
      $class = "OrganizationalUnit",
      $name,
      [switch]$debug,
      [switch]$help
     )
Function GetHelp()
{
 "SYNTAX: CreateObject_Param.ps1 -name `'cn=myuser,ou=testou`' -class user"
} #end GetHelp

Function CreateAdObject()
{
 Write-Debug "Connecting to $path"
 $adsi = [adsi]"LDAP://$path"
 Write-Debug "Creating $class, $name"
 $de = $adsi.Create($class,$name)
 $de.SetInfo()
} #end CreateAdObject

# *** Entry Point ***
if($debug) { $DebugPreference = "continue" }
If($help) { GetHelp ; exit }
if($name) { CreateAdObject ; exit }
if(!$name) { "Missing name of object!" ; GetHelp ; exit }