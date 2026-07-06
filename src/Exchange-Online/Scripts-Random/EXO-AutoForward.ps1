# Purpose: EXO-AutoForward — 177.240.246.94 Online mailbox and mail flow administration.
#   James Wylde

#----------------------------------------------------------------------------------------#
#   Modules

Set-Mailbox -Identity "person@email.com" -DeliverToMailboxAndForward $true -ForwardingAddress "person2@email.com"

Set-Mailbox -Identity "person@email.com" -ForwardingAddress $Null -ForwardingSmtpAddress $Null

Set-Mailbox -Identity "person@email.com" ForwardingAddress "person2@email.com"

Get-Mailbox -Identity "person@email.com" | Format-List ForwardingAddress,DeliverToMailboxAndForward



