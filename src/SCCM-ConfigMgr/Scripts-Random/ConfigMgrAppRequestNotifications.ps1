# Purpose: ConfigMgrAppRequestNotifications — Configuration Manager collections and deployments.
Function SendEmail {
            
        # Update the SMTP Server name/IP address
        Send-MailMessage -From "ConfigMgr <ConfigMgr@contoso.com>" -To $email -Subject "New ConfigMgr App Request" -Body "$body" -Priority High -DNO OnFailure -SMTPServer "localhost"
        }

# Update your to you ConfigMgr installation directory and Site Code
Import-Module "E:\Program Files\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1"
CD HQC:

# App requests for the apps listed in the $array below, are emailed to the Service Desk and a ticket is created and routed to the licesning team.
# All other app requests are sent directly to the Configmgr team. The application names must be identical to the name in each respective application.
$array = (
            "Microsoft Power BI", `
            "Collector for ArcGIS", `
            "Visio Professional 2013", `
            "Project Professional 2013", `
            "Dreamweaver CS", `
            "Dragon Naturally Speaking", `
            "LiveCycle Designer ES4", `
            "Creative Cloud Web Tools x64", `
            "Creative Cloud Video Tools x64", `
            "Creative Cloud Design Tools x64", `
            "Creative Cloud Core Utilities x64"
            )

# This queries for new 'Requested' apps opened within the last 29 minutes.
$Requests = Get-CMApprovalRequest | ? { $_.CurrentState -eq 1 -and $_.LastModifiedDate -ge (Get-Date).AddMinutes(-29) }

# Loops through each request and fires off an email to the respective recipient.
foreach ( $Request in $Requests )
    
{ 
    [string]$app = $Request.Application
    [string]$user = $Request.User.Split("\")[1]
    [string]$usercomments = $Request.Comments
    [string]$history = $Request.RequestHistory
    [string]$state = $Request.CurrentState
        $guid = $Request.RequestGuid
        $date = $Request.LastModifiedDate
        if ( $Request.CurrentState -eq '1')
            { $state = 'Requested' }
                elseif ( $Request.CurrentState -eq '2')
                    { $state = 'Cancelled' }
                elseif ( $Request.CurrentState -eq '3')
                    { $state = 'Denied' }
                elseif ( $Request.CurrentState -eq '4')
                    { $state = 'Approved' }
                else { $state = 'Not Requested' } 

        $notes ="This application was requested on $date. `
                        Please log into the ConfigMgr console to respond to this request."
        #email body
        $body = " 
            1| $app `
            2| $user `
            3| $usercomments `
            4| $notes `
            "
            
        if ($array -contains $request.Application) {
            # This targets the Service Desk / Procurement Dept. All apps that are listed in the $array above.
            $email = "ServiceDesk@contoso.com"
            SendEmail
            
            # modify the file path in the Out-File or remove if logging is not necessary
            "Request on behalf of $user for $app sent to Remedy on $date" | Out-File -FilePath 'F:\scripts\SentApprovalEmails.log' -Encoding default -Append
        
                    }

        else {
            # This targets the ConfigMgr Admin email. All requested apps that are not listed above.
            $email = "ConfigMgrAdmins@contoso.com"
            SendEmail

            # modify the file path in the Out-File or remove if logging is not necessary
            "Request on behalf of $user for $app sent to SCCM team on $date" | Out-File -FilePath 'F:\scripts\SentApprovalEmails.log' -Encoding default -Append

            }

    }