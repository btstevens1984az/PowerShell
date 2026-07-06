# Purpose: o365-exo DisableMailboxesForwarding — Microsoft 365 tenant administration.
## Disable all mailbox forwarding
Get-Mailbox | Set-Mailbox -ForwardingAddress $null
Get-Mailbox | Set-Mailbox -ForwardingSmtpAddress $null