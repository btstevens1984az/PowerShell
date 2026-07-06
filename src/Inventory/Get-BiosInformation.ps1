# Purpose: Get-BiosInformation — Hardware and software inventory collection.
# ------------------------------------------------------------------------
# DATE: 7/24/2009
#
# KEYWORDS: Get-WmiObject, best practice
#
# COMMENTS: This script retrurns bios information
#
#
#
#
# ------------------------------------------------------------------------
Param(
  [string]$computerName
) #end param

Function Get-BiosInformation($computerName)
{
 Get-WmiObject -class Win32_Bios -computername $computername
} #end function Get-BiosName

# *** Entry Point To Script ***
If(-not($computerName)) { $computerName = $env:computerName }
Get-BiosInformation -computerName $computername