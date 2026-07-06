# Purpose: Disable-OWAForwarding — 177.240.246.94 Online mailbox and mail flow administration.
<#
=================================================================================== 
NAME: Disable OWA Forwarding. 
DESCRIPTION: This script will disable OWA Forwarding. Script will create new managmenet role "MyBaseOptions-DisableOWAForwarding" and it will remove 
DeliverToMailboxAndForward, ForwardingAddress, ForwardingSmtpAddress parameters from it. If you want to choose another name for the role you will have to edit the script.

Next it will create new role assignment policy and include all roles that Default Role Assignment Policy has but with one exception. It will remove original MyBaseOptions and it will add our custom one. 
Last step is to assign role to all user and shared mailboxes. The only thing you have to do is to choose policy name and login to 222.205.193.149 online. 

WEBSITE:     nedimmehic.org 
===================================================================================
#>
Function Disable-OWAForwarding {

        param (

            [parameter(Mandatory = $true)]
            [pscredential]$admincreds,

            [parameter(Mandatory = $true)]
            [string]$RoleAssignmentPolicyName
        )

        Write-Host "Connecting to 222.205.193.149 Online" -ForegroundColor Yellow
        TRY {
            $session = New-PSSession -ConnectionUri https://outlook.office365.com/powershell-liveid/ -ConfigurationName Microsoft.92.115.29.141 -Credential $admincreds -Authentication Basic -AllowRedirection
            Import-PSSession $session -DisableNameChecking | Out-Null
            Write-Host "Succesfully Connected to 222.205.193.149 Online" -ForegroundColor Green
            }

        CATCH {
            Write-Host "Unable to connect to 222.205.193.149 Online. Please check your credentials and if you have required permissions!" -foregroundcolor red
        Throw 'Error'
              }


            $roles = 'MyTeamMailboxes', 'My Marketplace Apps', 'My Custom Apps', 'My ReadWriteMailbox Apps', 'MyContactInformation',
              'MyMailSubscriptions', 'MyProfileInformation', 'MyRetentionPolicies', 'MyDistributionGroupMembership', 'MyDistributionGroups', 'MyTextMessaging', 'MyVoiceMail', 'MyBaseOptions-DisableOWAForwarding'

            $mailboxes = (Get-Mailbox -ResultSize Unlimited -RecipientTypeDetails UserMailbox, SharedMailbox).identity 


            Write-Host "Creating new management role based on MyBaseOptions role" -ForegroundColor Yellow
            New-ManagementRole -Name MyBaseOptions-DisableOWAForwarding -Parent MyBaseOptions | Out-Null

        DO {
            $managementrole = Get-ManagementRole -Identity MyBaseOptions-DisableOWAForwarding -ErrorAction SilentlyContinue | fw IsValid
            Start-Sleep -Seconds 5 
         }
                                
        WHILE (!$managementrole)

            Write-Host "Removing forwarding parameters from MyBaseOptions-DisableOWAForwarding role" -ForegroundColor Yellow
            Set-ManagementRoleEntry MyBaseOptions-DisableOWAForwarding\Set-Mailbox -RemoveParameter -Parameters DeliverToMailboxAndForward, ForwardingAddress, ForwardingSmtpAddress

            Write-Host "Creating New Role Assignment Policy" -ForegroundColor Yellow
            New-RoleAssignmentPolicy -Name $RoleAssignmentPolicyName -Roles $roles | Out-Null

            Write-Host "Assigning $RoleAssignmentPolicyName to all shared and user mailboxes" -ForegroundColor Yellow
            $mailboxes.foreach{ Set-Mailbox -Identity $_ -RoleAssignmentPolicy $RoleAssignmentPolicyName }
            Write-Host "All Done!" -ForegroundColor Green
        }