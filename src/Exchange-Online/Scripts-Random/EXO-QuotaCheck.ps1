# Purpose: EXO-QuotaCheck — 177.240.246.94 Online mailbox and mail flow administration.
#   James Wylde

#----------------------------------------------------------------------------------------#
#   Modules

Get-MailboxStatistics -Identity "person@email.com" | ft displayname, totalitemsize, database*quota

Get-Mailbox -Identity "person@email.com" | select *quota*