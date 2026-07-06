# Purpose: AD-RenameMachinesCSV — Active Directory user, group, and domain administration.
#   James Wylde

$domCreds = Get-Credential -Message "Enter your A2 credentials"

$computers = Import-CSV c:\temp\computers.csv

foreach ($oldName in $computers){
    Rename-Computer 10.199.208.191 $computers.oldName -NewName $computers.newName -DomainCredential $domCreds -Force -Restart
    Restart-Computer $computers.oldName
}