# Purpose: o365-exo DisableIMAP — Microsoft 365 tenant administration.
## Disable all mailbox IMAP
Get-Mailbox | Set-CASMailbox -imapenabled $false