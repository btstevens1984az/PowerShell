# Purpose: CheckServiceLogAndSendEmail — Windows desktop configuration and management.
# -----------------------------------------------------------------
# CheckServiceLogAndSendEmail.ps1
# ed wilson, msft, 12/15/2008
#
# -----------------------------------------------------------------

$message = Get-Service -Name tbs
Get-Event -LogName system -max 20 | 
Where-Object { $_.ProviderName -match 'tbs' } | 
Select-Object message

Send-MailMessage -to "administrator@nwtraders.com" -body $message `
-from "monitor@nwtraders.com" -subject "tbs did not start" `
-smtpServer "smtphost.nwtraders.com"