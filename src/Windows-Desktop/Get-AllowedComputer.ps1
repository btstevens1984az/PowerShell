# Purpose: Get-AllowedComputer — Windows desktop configuration and management.
# ------------------------------------------------------------------------
# DATE: 7/7/2009
#
# KEYWORDS: Function, Get-Content, Get-WmiObject
# 
# COMMENTS: This script reads a text file with computer
# names on each line. It create an array of computer names
# and uses the -contains operator to determine if the 
# computer name passed from the command line is on the
# allowed list of comptuers. This is not a security measure, 
# but a method of ensuring that the computer name was
# typed properly
#
# ------------------------------------------------------------------------
Param([string]$computer = $env:computername)

Function Get-AllowedComputer([string]$computer)
{
 $servers = Get-Content -path c:\fso\servers.txt 
 $servers -contains $computer
} #end Get-AllowedComputer function

# *** Entry point to Script ***

if(Get-AllowedComputer -computer $computer)
 {
   Get-WmiObject -class Win32_Bios -Computer $computer
 }
Else
 {
  "$computer is not an allowed computer"
 }