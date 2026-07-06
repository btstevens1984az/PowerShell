# Purpose: o365-exo DisableIMAP_and_POP3_ForNewUsers — Microsoft 365 tenant administration.
## Disable IMAP and POP3 for new users
Get-CASMailboxPlan | Set-CASMailboxPlan -imapenabled $false -PopEnabled $false