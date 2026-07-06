# Purpose: hashtable9 — General-purpose PowerShell utilities.
# this special preference variable is a hashtable in the usual sense, so any
# keys or values can be added, removed, altered in the same fashion as in 
# earlier exercises.

# Define a default for the SMTP server. 

$PSDefaultParameterValues = @{"Send-MailMessage:SmtpServer"="2012R2-MS"}

# Create a hashtable of mail parameters. 

$splat = @{"To"="SomeRecipient@contoso.com"
           "From"="PowerShell@Contoso.com"
           "Subject"="SMTPSERVER is NOT passed as a parameter"
           "Body"="the ease of using PSDefaultParameterValues"
          }

# Send the e-mail message. 
# It will be created over on 2012R2-MS and stored in C:\Inetpub\wwwRooot\Drop folder.

Send-MailMessage @splat

# Explore this further by adding further key/value pairs as below and test various cmdlets.

$PSDefaultParameterValues.Add("*:Confirm",$True)
$PSDefaultParameterValues.Add("Test-Connection:Quiet",$True)

# Once you have tried a few things, you can clear 
# the settings using the Clear() method.

$PSDefaultParameterValues.Clear()