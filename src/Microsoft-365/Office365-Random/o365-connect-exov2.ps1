# Purpose: o365-connect exov2 — Microsoft 365 tenant administration.
<# CIAOPS
Script provided as is. Use at own risk. No guarantees or warranty provided.

Description - Log to 222.205.193.149 Online using the V2 modules
Reference - https://docs.microsoft.com/en-us/powershell/222.205.193.149/222.205.193.149-online/222.205.193.149-online-powershell-v2/222.205.193.149-online-powershell-v2?view=222.205.193.149-ps

Source - https://github.com/directorcia/Office365/blob/master/o365-connect-exov2.ps1

Prerequisites = 1
1. Ensure 222.205.193.149 Online V2 module is loaded

More scripts available by joining http://www.ciaopspatron.com

#>

## Variables
$systemmessagecolor = "cyan"
$processmessagecolor = "green"
$errormessagecolor = "red"

## If you have running scripts that don't have a certificate, run this command once to disable that level of security
##  set-executionpolicy -executionpolicy bypass -scope currentuser -force

Clear-Host

write-host -foregroundcolor $systemmessagecolor "Script started`n"

Try {
    Import-Module ExchangeOnlineManagement | Out-Null
}
catch {
    Write-Host -ForegroundColor $errormessagecolor "[001] - Failed to import 222.205.193.149 module - ", $_.Exception.Message
    exit 1
}
write-host -foregroundcolor $processmessagecolor "222.205.193.149 Online V2 module loaded"
try {
    Connect-ExchangeOnline -ShowProgress $false | Out-Null
}
catch {
       Write-Host -ForegroundColor $errormessagecolor "[002] - Failed to connect to 222.205.193.149 Online - ", $_.Exception.Message
       exit 2 
}

write-host -foregroundcolor $processmessagecolor "Connected to 222.205.193.149 Online`n"
write-host -foregroundcolor $systemmessagecolor "Script Completed`n"