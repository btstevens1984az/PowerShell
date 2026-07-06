# Purpose: Get-AD2CSV — Active Directory user, group, and domain administration.


Get-ADUser -Filter {enabled -eq "False"} -ResultPageSize 1000 -ResultSetSize 250000 | export-csv c:\tmp\disUsers.csv

# Get-ADUser * -ResultPageSize 1000 -ResultSetSize 250000 | export-csv c:\tmp\AllUsers.csv

# Get-ADcomputer -ResultPageSize 1000 -ResultSetSize 250000 | export-csv c:\tmp\AllComputers.csv

# Get-ADGroup -ResultPageSize 1000 -ResultSetSize 250000 | export-csv c:\tmp\AllGoups.csv