# Purpose: Get-BiosParam — Hardware and software inventory collection.
# ------------------------------------------------------------------------
# DATE: 5/11/2009
#
# KEYWORDS: Get-WmiObject, Win32_Bios, param
# named arguments
#
# COMMENTS: This script illustrates accepting a command
# line argument. When the script is run, the computer name
# may be supplied. Default is to run locally
# Ex: Get-BiosParam -computer localhost
#
# ------------------------------------------------------------------------
Param($computer = "localhost")
Get-WmiObject -Class win32_bios -computername $computer
