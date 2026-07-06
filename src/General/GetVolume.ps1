# Purpose: GetVolume — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE: 12/24/2008
#
# KEYWORDS: WMI, Volume, Desktop management
#
# COMMENTS: This script uses a function to return information
# using Win32_Volume WMI class. It will work remotely
#
#
#
# ------------------------------------------------------------------------
Param($drive = "C:", $computer = "localhost")
Function Get-Volume($drive, $computer)
{
 $drive += "\\"
 Get-WmiObject -Class Win32_Volume -computerName $computer `
 -filter "Name = '$drive'"
}

Get-Volume -Drive $drive -Computer $computer