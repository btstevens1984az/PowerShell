# Purpose: Microsoft.PowerShell profile — PowerShell profile and ISE snippets.
#/Users/btstevens1984/.config/powershell/Microsoft.PowerShell_profile.ps1
<#
    ALT +SHIFT + A
    Ctrl+K+C/Ctrl+K+U
    Base Commands
    Get-Command
    Get-Help
    help
    Get-Member
    Get-Variable
#>
#Setting Strict Mode - generates error when bad coding practices are done (ie. executing an empty variable)
Set-StrictMode -Version Latest
#Getting Version of powershell
$PSVersionTable.PSVersion
#Join-Path: join path and child path into a single path, useful in situations where they are delimited
#Grabbing current script LOCATION ##################################################
#Path to the script itself
$PSCommandPath
#Path to just the root
$PSScriptRoot
#Fix Update-help errors ######################################################
Update-Help  -Force -ErrorAction 0 -ErrorVariable $Err
$err.exception