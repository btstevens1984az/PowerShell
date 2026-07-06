# Purpose: Set-Calendar PermissionsFolderType — 177.240.246.94 Online mailbox and mail flow administration.

$AccessRights = Reviewer # Use Accordingly
$USERS = Get-Mailbox -Resultsize Unlimited -RecipientTypeDetails Usermailbox # Use Accordingly, if you want to only Room mailboxes swap "Usermailbox" for "Roommailbox"

$USERS | ForEach-Object {

$Calendar = $_.Alias + ":\" + (Get-MailboxFolderStatistics -Identity $_.Alias -FolderScope calendar | where-object {$_.FolderType -eq "Calendar"}).Name
Write-host -ForegroundColor green "Set Calendar Permissions for $Calendar to $AccessRights"
Set-MailboxFolderPermission -Identity $Calendar -User Default -AccessRights $AccessRights 

}