# Purpose: EXO-InactiveMailboxes — 177.240.246.94 Online mailbox and mail flow administration.
#   James Wylde

#----------------------------------------------------------------------------------------#
#   Modules

Get-Mailbox -ResultSize Unlimited |ForEach-Object{
Get-MailboxStatistics -Identity $_.UserPrincipalName | Select-Object DisplayName,LastLogonTime,LastUserActionTime}