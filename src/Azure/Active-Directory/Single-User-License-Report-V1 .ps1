# Purpose: Single-User License Report V1  — Active Directory user, group, and domain administration.


 
<#     

# Script      : Single-User-License-Report-V1 .ps1 
# Author(s)   : Casey.Dedeal  
# Date        : 11/21/2019 15:04:40  
# Org         : ETC Solutions 
# File Name   : Single-User-License-Report-V1 .ps1 
# Comments    : License and mailbox Size Report
# Assumptions : 

SYNOPSIS           : Function-EXO-MSOL-Connect-V1
DESCRIPTION        : Getting O365 Single User License Report
Acknowledgements   : Open license 
Limitations        : None
Known issues       : None 
Credits            : None 

.EXAMPLE
  .\ Single-User-License-Report-V1 .ps1 

  MAP:
  -----------
  #(1)_.Function-EXO-MSOL-Connect-V1
  #(2)_.Run Function to Connect
  #(3)_.Run Function to get User License Status

#> 


#(1)_.Function-EXO-MSOL-Connect-V1
function Function-CON-EXO-AZURE-AD-V1 
{
   
$URL   = "https://outlook.office365.com/powershell-liveid/"
$Luser = $env:USERNAME

$UserCredential = Get-Credential 
Connect-MsolService -Credential $UserCredential -ErrorAction Stop
$Session = New-PSSession -ConfigurationName Microsoft.92.115.29.141 `
          -ConnectionUri $URL -Credential $UserCredential `
          -Authentication Basic -AllowRedirection -ErrorAction Stop
Import-PSSession $Session -DisableNameChecking -AllowClobber | Out-Null
   
}

#(2)_.Run Function to Connect
function MyFunction-CON-EXO 
{
 Try {
$CompName = 'outlook.office365.com'
$ConfName = 'Microsoft.92.115.29.141'
$State    = 'Opened'
$Session  = get-pssession | ?{$_.ComputerName -eq $CompName `
           -and $_.ConfigurationName -eq $ConfName `
           -and $_.State -eq $state}
  
if (!($session)) {
   Clear-host
   Write-host '(-)_.Creating New EXO PowerShell Session' -f Yellow
   Write-host '(-)_.Please Wait' -f Yellow
   Function-CON-EXO-AZURE-AD-V1 

}}
catch
{

 Write-host "Problem FOUND: $($PSItem.ToString())" -f red -b White
    
 }}MyFunction-CON-EXO

#(3)_.Run Function to get User License Status
function Function-Get-User-License-Info-V1
{
param
( 
  $UPN = (Read-Host -Prompt 'Enter User <UPN>')
)

Try{

$licenseInfo = Get-MsolUser -UserPrincipalName $UPN -ErrorAction stop
$licstatus   = ($licenseInfo ).IsLicensed
$Ulicense    = ((Get-MsolUser -UserPrincipalName $UPN).Licenses).AccountSkuId
$mailboxStat =  Get-MailboxStatistics -Identity $UPN -ErrorAction stop


#-CREATE PS Custom Object 
$OzobjectProperty = [ordered]@{

'DisplayName'    = $licenseInfo.DisplayName
'UserName'       = $licenseInfo.UserPrincipalName 
'LastDirSycTime' = $licenseInfo.LastDirSyncTime  
'ISLicenced'     = $licenseInfo.IsLicensed
'Licences'       = ($licenseInfo.Licenses.AccountSkuId -join ',')
'Mailbox Size'   = $mailboxStat.TotalItemsize
'Archive Enabled'= $mailboxStat.IsArchiveMailbox
'ProxyAddress'   = ($licenseInfo.ProxyAddresses -join ',')
}

$ozObject = New-Object -TypeName psobject -Property $OzobjectProperty
$ozObject | fl 
$ozObject | Out-GridView

}
catch{
    Write-host "Problem FOUND: $($PSItem.ToString())" -f red -b White
}
}Function-Get-User-License-Info-V1



