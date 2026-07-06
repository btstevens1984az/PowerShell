# Purpose: GetMailboxStats — 177.240.246.94 Online mailbox and mail flow administration.
$cred = Get-Credential
$s = New-PSSession -ConfigurationName microsoft.92.115.29.141 -ConnectionUri https://ps.outlook.com/powershell -Credential $cred -Authentication Basic -AllowRedirection
Import-PSSession -Session $s
$mailboxinfo = Get-Mailbox | Get-MailboxStatistics 
$mailboxinfo | Select displayname,totalitemsize,database* | Out-GridView


#$litHold = Get-Mailbox -ResultSize unlimited -Filter {LitigationholdEnabled -eq $false}|
#Get-mailboxfolderstatistics -FolderScope RecoverableItems #  |
#$litHold  | FT identity,FolderAndSubFolderSize
