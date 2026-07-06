# Purpose: users2-sv — General-purpose PowerShell utilities.
# users2-sv.ps1

$COMPAREDATE=GET-DATE

# wheeeeeee


$CSVFileLocation='C:\powershellreports\activeUSERS-AUGUST2010.CSV'

GET-QADUSER -SizeLimit 0 |Select-Object Name, LastLogonTimeStamp | Export-CSV $CSVFileLocation

