# Purpose: Get-BiosArgsCheck2 — Hardware and software inventory collection.
# ------------------------------------------------------------------------
# DATE: 5/10/2009
#
# KEYWORDS: Get-WmiObject, Win32_Bios, $args
# command line arguments
#
# COMMENTS: This script illustrates accepting a command
# line argument. When the script is run, the computer name
# must be supplied. 
# Ex: Get-Bios localhost
#
# ------------------------------------------------------------------------
If(!$args.count) 
  {
   Throw "Please supply computer name"
  } #end if
Get-WmiObject -Class win32_bios -computername $args 
