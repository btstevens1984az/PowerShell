# Purpose: EXO-RestrictInbound — 177.240.246.94 Online mailbox and mail flow administration.
#   James Wylde

Set-Mailbox -identity "user.block@email.com" -AcceptMessagesOnlyFrom "user.exception@email.com"