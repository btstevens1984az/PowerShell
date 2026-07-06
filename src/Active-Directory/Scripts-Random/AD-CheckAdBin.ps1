# Purpose: AD-CheckAdBin — Active Directory user, group, and domain administration.
#   James Wylde

#----------------------------------------------------------------------------------------#
#   Modules

Get-ADObject -LDAPFilter:"(msds-lastknownrdn=*)" -IncludeDeletedObjects | Export-Csv -path C:\temp\adBin.csv

Get-ADObject -Filter (displayName -eq "*G-UK-NOR") -IncludeDeletedObjects -Restore-ADObject