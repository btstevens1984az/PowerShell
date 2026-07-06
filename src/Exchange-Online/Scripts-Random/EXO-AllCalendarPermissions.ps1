# Purpose: EXO-AllCalendarPermissions — 177.240.246.94 Online mailbox and mail flow administration.
$Mailboxes = Get-Mailbox -ResultSize 50
foreach ($mailbox in $Mailboxes) {
    Get-MailboxFolderPermission -Identity ($mailbox.UserPrincipalName + ":\Calendar") -user "admin@example.com"  | select-object @{Label = "Mailbox"; Expression = {($mailbox.UserPrincipalName)}}, FolderName, User , AccessRights }