# Purpose: Get-ValidWmiClassFunction — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE: 7/8/2009
#
# KEYWORDS: Function, $errorActioinPreference, 
# $error.clear, [wmiclass], wmiclass type accelerator,
# error.count
# COMMENTS: This script uses a function to see if a 
# wmiclass is a valid wmi class. If it is, then it calls another
# function to perform the wmi query. The important function
# if the Get-ValidWmiClass function. 
#
# ------------------------------------------------------------------------
Param (
   [string]$computer = $env:computername, 
   [string]$class, 
   [string]$namespace = "root\cimv2"
) #end param

Function Get-ValidWmiClass([string]$computer, [string]$class, [string]$namespace)
{
 $oldErrorActionPreference = $errorActionPreference
 $errorActionPreference = "silentlyContinue"
 $Error.Clear()
 [wmiclass]"\\$computer\$($namespace):$class" | out-null
 If($error.count) { Return $false } Else { Return $true }
 $Error.Clear()
 $ErrorActionPreference =  $oldErrorActionPreference
} # end Get-ValidWmiClass function

Function Get-WmiInformation ([string]$computer, [string]$class, [string]$namespace)
{
  Get-WmiObject -class $class -computername $computer -namespace $namespace|
  Format-List -property [a-z]*
} # end Get-WmiInformation function

# *** Entry point to script ***

If(Get-ValidWmiClass -computer $computer -class $class -namespace $namespace) 
  {
    Get-WmiInformation -computer $computer -class $class -namespace $namespace
  }
Else
 {
   "$class is not a valid wmi class in the $namespace namespace on $computer" 
 }