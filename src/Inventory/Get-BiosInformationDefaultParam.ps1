# Purpose: Get-BiosInformationDefaultParam — Hardware and software inventory collection.
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
  [string]$computerName = $env:computername
) #end param

Function Get-BiosInformation($computerName)
{
 Get-WmiObject -class Win32_Bios -computername $computername
} #end function Get-BiosName

# *** Entry Point To Script ***

Get-BiosInformation -computerName $computername