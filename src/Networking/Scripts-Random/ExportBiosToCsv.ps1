# Purpose: ExportBiosToCsv — Network diagnostics, DNS, DHCP, and connectivity.
# ------------------------------------------------------------------------
# DATE: 12/15/2008
#
# KEYWORDS: uses get-wmiobject, select-object
# export-csv
#
# COMMENTS: This script obtains the name, and version
# of the bios and writes to a csv file. 
#
# ------------------------------------------------------------------------

$path = "c:\fso\bios.csv"
Get-WmiObject -Class win32_bios |
Select-Object -property name, version |
Export-CSV -path $path -noTypeInformation