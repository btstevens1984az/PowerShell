# Purpose: Get-IPObjectDefaultEnabledFormatNonIPOutput — PowerShell automation.
# ------------------------------------------------------------------------
# DATE:2/18/2009
#
# KEYWORDS: Function, default value, type constraint,
# Get-WmiObject
# COMMENTS: This demonstrates a function that obtains
# information from WMI using the Win32_NetworkAdapterConfiguration
# class. It demonstrates use of a function with a type constraint
# a default value, and a single purpose function
#
# PowerShell Best Practices
# ------------------------------------------------------------------------
Function Get-IPObject([bool]$IPEnabled = $true)
{
 Get-WmiObject -class Win32_NetworkAdapterConfiguration -Filter "IPEnabled = $IPEnabled"
} #end Get-IPObject

Function Format-NonIPOutput($IP)
{ 
  Begin { "Index #  Description" }
  Process {
   ForEach ($i in $ip)
    {
     Write-Host $i.Index `t $i.Description
    } #end ForEach
 } #end Process
} #end Format-NonIPOutput

# *** Entry Point ***

$ip = Get-IPObject -IPEnabled $False
Format-NonIPOutput($ip)