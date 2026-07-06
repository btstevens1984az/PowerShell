# Purpose: FSOBiosToCsv — Hardware and software inventory collection.
# ------------------------------------------------------------------------
# DATE: 12/14/2008
#
# KEYWORDS: filesystemobject, get-wmiobject
#
# COMMENTS: This script uses the filesystemobject
# to create a csv file. 
#
#
#
# ------------------------------------------------------------------------
$path = "c:\fso\bios1.csv"
$bios = Get-WmiObject -Class win32_bios
$csv = "Name,Version`r`n"
$csv +=$bios.name + "," + $bios.version
$fso = new-object -comobject scripting.filesystemobject
$file = $fso.CreateTextFile($path,$true)
$file.write($csv)
$file.close()