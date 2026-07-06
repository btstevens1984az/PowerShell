# Purpose: EXO-MailboxPermission — 177.240.246.94 Online mailbox and mail flow administration.
#   James Wylde

#----------------------------------------------------------------------------------------#
#   Modules

Add-MailboxPermission "resource.to.access@email.com" -user "person.wanting.access@email.com" -AccessRights fullaccess -Confirm:$false

Add-RecipientPermission "shared.mailbox@email.com" -AccessRights SendAs -Trustee "person.wanting.access@email.com"