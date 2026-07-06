# Purpose: get-inactive computers 2 csv — Windows desktop configuration and management.

$COMPAREDATE=GET-DATE

# Number of Days to see if account has been active


$NumberDays=60


$CSVFileLocation='h:\inactivePCs\60days.CSV'

GET-QADCOMPUTER -SizeLimit 0 -IncludedProperties LastLogonTimeStamp | where { ($CompareDate-$_.LastLogonTimeStamp).Days -gt $NumberDays } | Select-Object Name, LastLogonTimeStamp, OSName, ParentContainerDN | Sort-Object ModificationDate, Name | Export-CSV $CSVFileLocation

