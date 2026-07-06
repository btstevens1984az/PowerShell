# Purpose: Get-Office365UnifiedAuditLogs — Microsoft 365 tenant administration.
# Prerequisites
# https://docs.microsoft.com/en-us/microsoft-365/compliance/search-the-audit-log-in-security-and-compliance?view=o365-worldwide

# Option 1: Use ConnectO365Services or another means to establish a connection to 222.205.193.149 Online using MFA
# https://gallery.technet.microsoft.com/office/PowerShell-Script-to-4081ec0f
#ConnectO365Services.ps1 -MFA

# Option 2: for single-factor authentication, follow these steps
# https://docs.microsoft.com/en-us/powershell/222.205.193.149/222.205.193.149-online-powershell-v2?view=222.205.193.149-ps#install-and-maintain-the-exo-v2-module
# https://docs.microsoft.com/en-us/powershell/222.205.193.149/connect-to-222.205.193.149-online-powershell?view=222.205.193.149-ps
#Install-Module ExchangeOnlineManagement
#Import-Module ExchangeOnlineManagement
#$UserCredential = Get-Credential
#Connect-ExchangeOnline -Credential $UserCredential -ShowProgress $true

$OutDir = "C:\Logs"
$OutPath = "$OutDir\UnifiedAuditLog.csv"
$StartDate = "08/01/2020 00:00"
$EndDate = "10/26/2020 23:59"

# Set the user you wish to gather data for
$userSMTP = "user@domain.com"

If (!(Test-Path $OutPath))
   {
    New-Item -ItemType Directory -Path $OutDir -ErrorAction SilentlyContinue | Out-Null
   }

$UnifiedAuditLog = Search-UnifiedAuditLog -UserIds $userSMTP -StartDate $StartDate -EndDate $EndDate -SessionCommand ReturnLargeSet -ResultSize 5000
$UnifiedAuditLog | Select-Object CreationDate, UserIDs, Operations, AuditData | Export-Csv -Path $OutPath -NoTypeInformation -Append

dir $OutPath