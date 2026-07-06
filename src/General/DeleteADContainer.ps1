# Purpose: DeleteADContainer — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE: Oct. 5, 2008
#
# KEYWORDS: adsi
#
# COMMENTS: uses Exists static method exists and base DeleteTree 
# method from System.DirectoryServices.DirectoryEntry class.
# This script will not work if the object was created with 
# "Protect this object from accidential deletion" 
#
# ------------------------------------------------------------------------
Param($path,[switch]$delete,[switch]$whatif,[switch]$help)

function GetHelp()
{
 $helpText= `
@"
 DESCRIPTION:
 NAME: DeleteADContainer.ps1
 Deletes object specified by path. This includes OU's that contain other 
 objects such as users, groups, or other organizationalUnits 

 PARAMETERS: 
 -Path path of object
 -Delete Deletes object specified by path parameter
 -Whatif Prototypes the command
 -Help displays this help topic

 SYNTAX:
 DeleteADContainer.ps1 -path 'ou=mytest,dc=nwtraders,dc=com' 
 Tests to see if can connect to LDAP://ou=mytest,dc=nwtraders,dc=com

 DeleteADContainer.ps1 -path 'ou=mytest,dc=nwtraders,dc=com' -delete
 Deletes object ou=mytest,dc=nwtraders,dc=com and all child objects in 
 that same container

 DeleteADContainer.ps1 -path 'ou=mytest,dc=nwtraders,dc=com' -whatif
 Displays following message: 
 WHAT IF: Perform operation Delete object ou=mytest,dc=nwtraders,dc=com

 DeleteADContainer.ps1 -help

 Prints the help topic for the script
"@ #end helpText
  $helpText
} #end GetHelp


Function whatif()
{
 "WHAT IF: Perform operation Delete object $path"
} #end whatif

Function TestPath()
{
 "Testing $adspath"
 If([adsi]::Exists("$adsPath"))
   {
    "$adsPath exists"
   }
 ELSE
   {
    "Unable to find $adsPath"
   }
} # end testpath

Function DeleteTree()
{
  $de = [adsi]"$adsPath"
  $de.psbase.deleteTree()
} #end DeleteTree 

# *** entry point ***

if($help) { getHelp ; exit }
if(!$path) { "Missing path" ; GetHelp ; exit }
if($whatif) { Whatif ; exit }

$adsPath = "LDAP`://$path"
If($path) { TestPath }
if($delete) { DeleteTree }
