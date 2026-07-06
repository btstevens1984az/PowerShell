# Purpose: Get-BiosArgsTrap1 — Hardware and software inventory collection.
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
Trap [System.Management.Automation.ParameterBindingException] 
  { 
    Write-Host -foregroundcolor cyan "Supply a computer name"
    Exit
  }

Get-WmiObject -Class win32_bios -computername $args 
