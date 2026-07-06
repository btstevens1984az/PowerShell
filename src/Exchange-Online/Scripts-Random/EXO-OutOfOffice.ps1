# Purpose: EXO-OutOfOffice — 177.240.246.94 Online mailbox and mail flow administration.
#   James Wylde

#----------------------------------------------------------------------------------------#
#   Modules

Set-MailboxAutoReplyConfiguration -Identity "person@email.com" -Autoreplystate Enabled -InternalMessage "InternalText" -ExternalMessage "ExternalText"

Set-MailboxAutoReplyConfiguration -Identity "person@email.com" -AutoReplyState Scheduled -StartTime "7/10/2018 08:00:00" -EndTime "7/15/2018 17:00:00" -InternalMessage "InternalText" -ExternalMessage "ExternalText"