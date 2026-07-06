# Purpose: inactivePCs — General-purpose PowerShell utilities.

$COMPAREDATE=GET-DATE

# Number of Days to see if account has been active


$NumberDays=60


# GET-QADCOMPUTER -SizeLimit 0 -IncludedProperties LastLogonTimeStamp | where { ($CompareDate-$_.LastLogonTimeStamp).Days -gt $NumberDays } | Move-QADcomputer -to OU=OldComputers,DC=example,DC=local

GET-QADCOMPUTER -SizeLimit 0 -IncludedProperties LastLogonTimeStamp | where { ($CompareDate-$_.LastLogonTimeStamp).Days -gt $NumberDays } | Export-CSV H:\inactiv60daysPCS.csv

