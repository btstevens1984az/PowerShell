# Purpose: get-ADCompPWDLastSet — Active Directory user, group, and domain administration.

# $COMPAREDATE=GET-DATE

# Number of Days to see if account has been active


# $NumberDays=60

# $CSVFileLocation='C:\ps\60days.CSV'

# GET-ADCOMPUTER -SizeLimit 0 -IncludedProperties LastLogonTimeStamp | where { ($CompareDate-$_.LastLogonTimeStamp).Days -gt $NumberDays } | Select-Object Name, LastLogonTimeStamp, OSName, ParentContainerDN | Sort-Object ModificationDate, Name | Export-CSV $CSVFileLocation

# $CSVFileLocationDisabledUsers='U:\ADReports\disabledUsersDH1.CSV'

#GET-ADUser -Filter [enabled -eg "False"} -IncludedProperties LastLogonTimeStamp -SizeLimit 0 | Select-Object Name, LastLogonTimeStamp, ParentContainerDN, AccountIsDisabled | Sort-Object ParentContainerDN | Export-CSV $CSVFileLocationDisabledUsers

# GET-ADUser -Filter [enabled -eg "False"} -IncludedProperties LastLogonTimeStamp -SizeLimit 0 | Select-Object Name, LastLogonTimeStamp, ParentContainerDN, AccountIsDisabled | Sort-Object ParentContainerDN | Export-CSV $CSVFileLocationDisabledUsers

#get-aduser -filter {PasswordExpired -eq "true"} | select name |FT
#get-aduser -Filter {name -like "w*"} and {Enabled -eq "False"} | Select-Object name, enabled |ft
#get-aduser -Filter {Enabled -eq "False"} | Select-Object name, enabled |ft

get-adcomputer -filter * -Properties PasswordLastSet -ResultSetSize $null |select-object Name, Enabled, PasswordLastSet | export-csv C:\tmp\ADPWLast.csv -NoTypeInformation