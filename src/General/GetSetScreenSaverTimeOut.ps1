# Purpose: GetSetScreenSaverTimeOut — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE: 12/26/2008
#
# KEYWORDS: debug, registry, get-Itemproperty, get-item
# ref, pass by reference
# COMMENTS: This script uses the get-itemproperty and
# set-itemproperty cmdlets to read/set the screensaver
# time out values. it also uses the write-debug cmdlet to
# provide debug information. This also uses the 
# $myInvocation.MyCommand.Name value to display
# the name of the function
# 
# ------------------------------------------------------------------------
Param([switch]$debug)
Function Get-RegistryValue([ref]$in)
{
 Write-Debug $MyInvocation.MyCommand.name
 $in.value = (Get-ItemProperty -path $path -name $name).$name
} #end Get-RegistryValue

Function Set-RegistryValue($value)
{
 Write-Debug $MyInvocation.MyCommand.name
 Set-ItemProperty -Path $path -name $name -value $value
} #end Get-RegistryValue

Function Write-Feedback($in)
{
 Write-Debug $MyInvocation.MyCommand.name
 "The $name is set to $($in)"
} #end Write-Feedback

# *** Entry Point ***
if($debug) { $DebugPreference = "continue" }
$path = 'HKCU:\Control Panel\Desktop'
$name = 'ScreenSaveTimeOut'
$in = $null
$value = 600

Get-RegistryValue([ref]$in)
Write-Feedback($in)
Set-RegistryValue($value)
Get-RegistryValue([ref]$in)
Write-Feedback($in)
