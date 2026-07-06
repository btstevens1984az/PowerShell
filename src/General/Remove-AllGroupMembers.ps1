<#
   .Synopsis
    Removes all members of a group
   .Description
    This script removes all members of a group
   .Example
    Remove-AllGroupMembers.ps1 -group cn=mygroup -ou ou=myou `
    -domain 'dc=nwtraders,dc=com
    Removes all members of the mygroup group in the myou organizational unit
    of the nwtraders.com domain
   .Example
    Remove-AllGroupMembers.ps1 -group cn=mygroup -ou ou=myou `
    -domain 'dc=nwtraders,dc=com' -whatif
    Displays: WHATIF: Remove all members from cn=mygroup,ou=myou, 
    dc=nwtraders,dc=com
   .Inputs
    [string]
   .OutPuts
    [string]
    KEYWORDS: adsi, groups, powershell best practice
   .Link
     Http://www.ScriptingGuys.com
#Requires -Version 2.0
#>
[CmdletBinding()]
Param(
   [Parameter(Mandatory=$true)]
   [string]$group,
   [Parameter(Mandatory=$true)]
   [string]$ou,
   [Parameter(Mandatory=$true)]
   [string]$domain,
   [switch]$whatif
) #end param

# *** Functions ***
Function Remove-AllGroupMembers
{
 Param(
   [string]$group,
   [string]$ou,
   [string]$domain
 ) #end param
 $ads_Property_Clear = 1
 $de = [adsi]"LDAP://$group,$ou,$domain"
 $de.putex($ads_Property_Clear,"member",$null)
 $de.SetInfo()
} # end function Remove-AllGroupMembers

Function Get-Whatif
{
  Param(
   [string]$group,
   [string]$ou,
   [string]$domain
 ) #end param
 "WHATIF: Remove all members from $group,$ou,$domain" 
} #end function Get-Whatif

# *** Entry Point to script ***

if($whatif) { Get-Whatif -group $group -ou $ou -domain $domain ; exit }
"Removing all members from $group,$ou,$domain"
Remove-AllGroupMembers -group $group -ou $ou -domain $domain