# Purpose: MandatoryParameter — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE: 7/24/2009
#
# KEYWORDS: mandatory parameter
#
# COMMENTS: This script uses a mandatory parameter
# to force the choice of a value. 
# ex: MandatoryParameter.ps1 -drive "c:" 
# 
#
# ------------------------------------------------------------------------
#Requires -version 2.0
Param(
   [Parameter(Mandatory=$true)]
   [string]$drive,
   [string]$computerName = $env:computerName
) #end param

Function Get-DiskInformation($computerName,$drive)
{
 Get-WmiObject -class Win32_volume -computername $computername -filter "DriveLetter = '$drive'"
} #end function Get-BiosName

# *** Entry Point To Script ***

 Get-DiskInformation -computername $computerName -drive $drive