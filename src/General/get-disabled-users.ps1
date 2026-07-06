# Purpose: get-disabled users — General-purpose PowerShell utilities.

# $COMPAREDATE=GET-DATE

# Number of Days to see if account has been active


# $NumberDays=60

# $CSVFileLocation='C:\ps\60days.CSV'

# GET-ADCOMPUTER -SizeLimit 0 -IncludedProperties LastLogonTimeStamp | where { ($CompareDate-$_.LastLogonTimeStamp).Days -gt $NumberDays } | Select-Object Name, LastLogonTimeStamp, OSName, ParentContainerDN | Sort-Object ModificationDate, Name | Export-CSV $CSVFileLocation

$CSVFileLocationDisabledUsers='U:\ADReports\disabledUsersDH1.CSV'

GET-ADUser -disabled -IncludedProperties LastLogonTimeStamp -SizeLimit 0 | Select-Object Name, LastLogonTimeStamp, ParentContainerDN, AccountIsDisabled | Sort-Object ParentContainerDN | Export-CSV $CSVFileLocationDisabledUsers