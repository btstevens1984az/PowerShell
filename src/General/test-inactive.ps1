# Purpose: test-inactive — General-purpose PowerShell utilities.
﻿$COMPAREDATE=GET-DATE

# 

#

# Number of Days to see if account has been active

#

$NumberDays=90

#

$CSVFileLocation='C:\ADREPORTS\OldComps.CSV'

#

#

GET-QADCOMPUTER -SizeLimit 0 -IncludedProperties LastLogonTimeStamp | where { ($CompareDate-$_.LastLogonTimeStamp).Days -gt $NumberDays } | Select-Object Name, LastLogonTimeStamp, OSName, ParentContainerDN | Sort-Object ModificationDate, Name | Export-CSV $CSVFileLocation

}