# Purpose: Test-ComputerPath — Windows desktop configuration and management.
# ------------------------------------------------------------------------
# DATE: 7/7/2009
#
# KEYWORDS: function, win32_pingstatus
#
# COMMENTS: This script uses the win32_pingstatus 
# wmi class in a function to ping a host prior to querying
# a wmi class. If the ping fails, then the script does not
# attempt to query the wmi class. 
#
# ------------------------------------------------------------------------
Param([string]$computer = "localhost")

Function Test-ComputerPath([string]$computer)
{
 Get-WmiObject -class win32_pingstatus -filter "address = '$computer'"
} #end Test-ComputerPath

# *** Entry Point to Script ***

if( (Test-ComputerPath -computer $computer).statusCode -eq 0 ) 
 {
  Get-WmiObject -class Win32_Bios -computer $computer
 }
Else
 {
  "Unable to reach $computer computer"
 }