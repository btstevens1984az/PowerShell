<#
   .Synopsis
    Adds a user to multiple groups
   .Description
    This script adds a user to one or more groups. User and group 
     must be in same OU
   .Example
    Add-UserToGroups.ps1 -user cn=myuser -group cn=mygroup `
    -ou ou=myou -domain 'dc=nwtraders,dc=com'
    Adds the user myuser to the group mygroup in the myou ou in the
    nwtraders.com domain. 
   .Example
    Add-UserToGroups.ps1 -user cn=myuser -group cn=mygroup1,cn=mygroup2 `
    -ou ou=myou -domain 'dc=nwtraders,dc=com'
    Adds the user myuser to both the mygroup1 and the mygroup2 groups in the 
    myou ou in the nwtraders.com domain. 
   .Example
    Add-UserToGroups.ps1 -user cn=myuser -group cn=mygroup `
   -ou ou=myou -domain     'dc=nwtraders,dc=com' -whatif
   Displays WhatIf: Add user cn=myuser,ou=myou,dc=nwtraders,dc=com to `
   cn=mygroup,ou=myou,dc=nwtraders,dc=com 
   .Inputs
    [String]
   .OutPuts
    [string]
    KEYWORDS: ADSI accelerator, best practices, debug
   .Link
     Http://www.ScriptingGuys.com
#Requires -Version 2.0
#>
[CmdletBinding()]
Param(
   [Parameter(Mandatory=$true)]
   [string[]]$group,
   [Parameter(Mandatory=$true)]
   [string]$user,
   [Parameter(Mandatory=$true)]
   [string]$ou,
   [Parameter(Mandatory=$true)]
   [string]$domain,
   [switch]$whatif
) #end param

# *** Functions ***
Function Add-UserToGroups
{
 Param(
   [string[]]$group,
   [string]$user,
   [string]$ou,
   [string]$domain
 ) #end param
 $ads_Property_Append = 3
 ForEach($g in $group)
 {
   write-debug "Connecting to group: LDAP://$g,$ou,$domain" 
   $de = [adsi]"LDAP://$g,$ou,$domain"
   write-debug "Putting user: $user,$ou,$domain"
   $de.putex($ads_Property_Append,"member", @("$user,$ou,$domain"))
   Write-debug "calling setinfo"
   $de.SetInfo()
  } #end foreach
} # end function Add-UserToGroups

Function Get-Whatif
{
  Param(
   [string[]]$group,
   [string]$user,
   [string]$ou,
   [string]$domain
 ) #end param
 ForEach($g in $group)
  {
   "WHATIF: Add user $user,$ou,$domain to $g,$ou,$domain" 
  } #end foreach
} #end function Get-Whatif

# *** Entry Point to script ***
if($debug) { $debugPreference = "continue" }
if($whatif) { Get-Whatif -user $user -group $group -ou $ou -domain $domain ; exit }

 Write-Debug "Adding user to group ..."
 Write-Debug "Calling Add-UserToGroups function."
 Write-Debug "passing: user $user group $group ou $ou domain $domain"

Add-UserToGroups -user $user -group $group -ou $ou -domain $domain