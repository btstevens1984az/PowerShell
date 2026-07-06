# Purpose: GetDrivesCheckAllowedValue — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE: 7/24/2009
#
# KEYWORDS: get-wmiobject, win32_volume,
# boundary check, mandatory parameter
# COMMENTS: This script checks the allowed values
# for win32_volume before executing the query.
#
#
# ------------------------------------------------------------------------
Param(
   [Parameter(Mandatory=$true)]
   [string]$drive,
   [string]$computerName = $env:computerName
) #end param

Function Check-AllowedValue($drive, $computerName)
{
 Get-WmiObject -class Win32_Volume -computername $computerName| 
 ForEach-Object { $drives += @{ $_.DriveLetter = $_.DriveLetter } }
 $drives.contains($drive)
} #end function Check-AllowedValue

Function Get-DiskInformation($computerName,$drive)
{
 Get-WmiObject -class Win32_volume -computername $computername -filter "DriveLetter = '$drive'"
} #end function Get-BiosName

# *** Entry Point To Script ***

if(Check-AllowedValue -drive $drive -computername $computerName)
  {
   Get-DiskInformation -computername $computerName -drive $drive
  }
else
 {
  Write-Host -foregroundcolor yellow "$drive is not an allowed value:"
 }