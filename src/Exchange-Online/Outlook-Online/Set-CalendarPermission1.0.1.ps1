Function Set-CalendarPermission1.0.1 {
<#
.SYNOPSIS
Apply/SET the Calendar Permissions on list of mailboxes and Permissions mentioned in the CSV File.

.DESCRIPTION
This is Set-CalendarPermission1.0.1 Function which can be used to set the Calendar Permissions.

        Name       : Set-CalendarPermission1.0.1
        DateUpdated: 03-Jan-2020 
        Blog       : https://www.technethub.com
        
.LINK
https://www.technethub.com

.EXAMPLE
PS> Set-CalendarPermission1.0.1 <CSV File Path>

For Example

Set-CalendarPermission1.0.1 C:\Temp\UserList.csv

.EXAMPLE

Set-CalendarPermission1.0.1

#>  [cmdletBinding()]
    param(
    [parameter(mandatory = $true, Position =0, HelpMessage="Please Enter the Path to CSV File")]
    [string]${Please Enter CSV File Path}
         )

#Loading the Variables with the CSV File Values 
Import-Csv ${Please Enter CSV File Path} -Header Mailbox, User, AccessRights | ForEach-Object{
                                                $MailboxName = $_.Mailbox
                                                $UserName = $_.User
                                                $AccessRights = $_.AccessRights

#Check to see if the user if enabled or not in Active Directory
If ($(Get-Aduser -filter {DisplayName -eq $MailboxName}).enabled -eq $false)
{
    
    Write-Host "$MailboxName" is a Disabled User Account in AD -ForegroundColor DarkYellow 
}
Else
{
 if (Get-Mailbox $MailboxName -ErrorAction SilentlyContinue)
 {
  Try{
     #Gathering the UserList who all are having permissions on the Calendar   
     $userList = Get-MailboxFolderPermission -Identity "$($MailboxName):\Calendar" | Select -ExpandProperty User | Select -Expandproperty DisplayName
     if ($userName -in $Userlist)
     {
      Write-Verbose "USERNAME IS IN USERLIST CHECKING USERRIGHTS"
      #Gathering the UserRights to check to match it against the csv file
      $userrights = Get-MailboxFolderPermission -Identity "$($MailboxName):\Calendar" -User "$userName" | Select -ExpandProperty AccessRights
      Write-Verbose "CHECKED USERRIGHTS, NOW COMPARING RIGHTS"
       if ($userrights -eq $AccessRights)
       { 
        #User Rights in CSV File Match the one assigned. Therefore, No Action will be required.
        WRITE-Verbose "USERALREADY HAVE PERMISSION"
        Write-Host User "$UserName" is having "$userrights" on "$MailboxName" Already NO ACTION REQUIRED. -ForegroundColor Green
       }                         
       Else
       {
       Write-Verbose "SETTING PERMISSION"
       #Set the Permissions if the UserRights does not Match with CSV File.
        Write-Host User "$UserName" already having permission assigned. Existing Permission "$Userrights" **** New Permission: "$accessrights"
        Write-Host SETTING Permissions as per the CSV File to "$AccessRights"
        Set-MailboxFolderPermission -Identity "$($MailboxName):\Calendar" -User "$UserName" -AccessRights $AccessRights
        Write-Host "Permission "$AccessRights" on User "$UserName" SET now." -ForegroundColor Black -BackgroundColor White
       }
     }
                      
    Else
    { 
     #Process ADD command if the user never been assigned any permissions on the Mailbox before.                             
     Write-Host User "$Username" is not having Permission on $MailboxName. Therefore will use the ADD Permission Now
     Write-Host "Processing ADD command for User $MailboxName" 
     If (Get-Mailbox $UserName -ErrorAction SilentlyContinue)
     {
      Add-MailboxFolderPermission -Identity "$($MailboxName):\Calendar" -User "$UserName" -AccessRights $AccessRights
     }
     Else { Write-Host ""$UserName" Mailbox does not exist - Can't ADD the Permission" -ForegroundColor Gray}
}
}

             
        Catch
        {
        Write-Warning $_
        }   

}

Else
{
 #Mailbox does not exist Message.
 Write-Host "$MailboxName" Mailbox does not exist -ForegroundColor Gray
}
  
}
}
}






