# Purpose: ReadHostQueryDrive — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE: 6/15/2009
#
# KEYWORDS: Get-WmiObject, Read-Host
# 
# COMMENTS: This script uses read-host and switch statement
# to choose drive letters to query
#
#
#
# ------------------------------------------------------------------------
$response = Read-Host "Type drive letter to query <c: / d:>"

Switch -regex($response) {
  "C" { Get-WmiObject -class Win32_Volume -filter "driveletter = 'c:'" }
  "D" { Get-WmiObject -class Win32_Volume -filter "driveletter = 'd:'" }
} #end switch