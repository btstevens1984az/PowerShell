# Purpose: 177.240.246.94 Loop Mailboxes  — Microsoft 365 tenant administration.
$mailboxes = Get-Mailbox -ResultSize unlimited
foreach ($mailbox in $mailboxes)
{
    Write-Host "Mailbox = ", $mailbox.primarysmtpaddress
    Write-Host "Audited items = ", $mailbox.auditadmin
    Write-Host
}