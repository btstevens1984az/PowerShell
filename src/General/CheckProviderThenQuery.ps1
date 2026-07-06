# Purpose: CheckProviderThenQuery — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE:
#
# KEYWORDS: Get-WmiObject, if ... else
#
# COMMENTS: This script checks for the existence of the
# wmi provider prior to executing a query
#
#
# ------------------------------------------------------------------------
If(Get-WmiObject -Class __provider -filter "name = 'cimwin32'")
 {
  Get-WmiObject -class Win32_bios
 }
Else
 {
  "Unable to query Win32_Bios because the provider is missing"
 }