# Purpose: AD-ExportGroupCSV — Active Directory user, group, and domain administration.
#   James Wylde

#----------------------------------------------------------------------------------------#
#   Modules
Import-Module ActiveDirectory

# Enabled
#Get-ADUser -Properties * -Filter {Enabled -eq 'True'} | Where-Object {($_.memberof -like "_UK DSS ALL")} | Select-Object @{Label = "Email";Expression = {$_.EmailAddress}}, @{Label = "First Name";Expression = {$_.GivenName}}, @{Label = "Last Name";Expression = {$_.Surname}}, @{Label = "Group";Expression = {($_.canonicalname -Split "/")[-2]}} | Export-Csv -Path c:\temp\export2.csv -NoTypeInformation



Get-ADGroupMember "group" | ForEach-Object  {Get-ADUser $_ -properties emailaddress} | Select-Object Name, SamAccountName, EmailAddress | Export-Csv -path C:\temp\ADGroupExport.csv


Get-ADGroupMember "group" | Select-Object name | Export-Csv -path C:\temp\export2.csv