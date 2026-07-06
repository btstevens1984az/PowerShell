# Purpose: GetDrivesValidRange — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE: 7/24/2009
#
# KEYWORDS: get-wmiobject, win32_volume,
# validRange, mandatory parameter
# COMMENTS: This script checks the allowed values
# for win32_volume before executing the query.
#
#
# ------------------------------------------------------------------------
Param(
   [Parameter(Mandatory=$true)]
   [ValidateRange("c","f")]
   [string]$drive,
   [string]$computerName = $env:computerName
) #end param

Function Get-DiskInformation($computerName,$drive)
{
 Get-WmiObject -class Win32_volume -computername $computername `
 -filter "DriveLetter = '$drive`:'"
} #end function Get-BiosName

# *** Entry Point To Script ***

Get-DiskInformation -computername $computerName -drive $drive
