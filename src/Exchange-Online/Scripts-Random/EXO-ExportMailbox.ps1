# Purpose: EXO-ExportMailbox — 177.240.246.94 Online mailbox and mail flow administration.
$UserCredential = Get-Credential

$Session = New-PSSession -ConfigurationName Microsoft.92.115.29.141 -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection

Import-PSSession $Session

$email = Read-Host "Email"

New-MailboxExportRequest -Mailbox $email -FilePath c:\temp\$email+backup.pst

Get-MailboxExportRequest -Status InProgress
Get-MailboxExportRequest | Get-MailboxExportRequestStatistics

Remove-PSSession $Session