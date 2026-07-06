# Purpose: SendMailHtml — System monitoring and alerting.
$cred = Get-credential
$params = @{
                SMTPServer = "smtp.office365.com"
                port = 587
                from = "Jeff@contoso.com"
                to = "Jeff@nwtraders.msft"
                credential = $cred
                subject = "test"
                BodyAsHtml = $true
                Body = Get-Process |Select processName,WS | sort WS -Descending | ConvertTo-Html -CssUri C:\temp\example.css | Out-String
                UseSSL = $true
            }
 Send-MailMessage @params