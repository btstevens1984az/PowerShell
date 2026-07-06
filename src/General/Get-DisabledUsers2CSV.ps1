# Purpose: Get-DisabledUsers2CSV — General-purpose PowerShell utilities.


Get-ADUser -Filter {enabled -eq "False"} -ResultPageSize 1000 -ResultSetSize 250000 | export-csv c:\tmp\disUsers.csv

# Get-ADUser * -ResultPageSize 1000 -ResultSetSize 250000 | export-csv c:\tmp\AllUsers.csv