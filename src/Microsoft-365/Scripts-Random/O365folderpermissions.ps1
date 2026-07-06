# Purpose: O365folderpermissions — Microsoft 365 tenant administration.

Get-MailboxFolderPermission -Identity jeff@contoso.com:\Calendar | Out-GridView -PassThru | ForEach-Object{
Remove-MailboxFolderPermission -Identity $_.identity -User $_.user.displayname -Verbose}





