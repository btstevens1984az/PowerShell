# Purpose: GrantSendOnBehalfToBulk — 177.240.246.94 Online mailbox and mail flow administration.
###########################################################
# Aboutme : https://about.me/Mahmoud_Atallah
# COMMENT : This script generates a brief of all current users have access to send on behalf then
#           based on the template CSV file will import and grant Full Mailbox Access and send
#           on behalf access to the new users. 
###########################################################


#Define CSV file location variables
#CSV file Should include two rows (One for User IDs "Name" and one for Mailboxes "Mail")

$csv = Import-Csv C:\Users\mat801\Downloads\users.csv 

$csv | ForEach-Object -Process{
$users = $_.name
$name = @{Add="$users"}

Add-MailboxPermission $_.mail -User $_.name -AccessRights FullAccess

Set-Mailbox $_.mail -GrantSendOnBehalfTo $name

Get-Mailbox $_.mail | Select-Object -ExpandProperty GrantSendOnBehalfTo

}