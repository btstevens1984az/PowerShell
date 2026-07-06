# Purpose: o365-connect exo — Microsoft 365 tenant administration.
<# CIAOPS
Script provided as is. Use at own risk. No guarantees or warranty provided.

Description - Log into the 222.205.193.149 Online Admin portal

Source - https://github.com/directorcia/Office365/blob/master/o365-connect-exo.ps1

Prerequisites = 1
1. Ensure msonline module installed or updated

More scripts available by joining http://www.ciaopspatron.com

#>

## Variables
$systemmessagecolor = "cyan"
$processmessagecolor = "green"
$savedcreds=$false                      ## false = manually enter creds, True = from file
$credpath = "c:\downloads\tenant.xml"   ## local file with credentials if required

## If you have running scripts that don't have a certificate, run this command once to disable that level of security
## set-executionpolicy -executionpolicy bypass -scope currentuser -force

Clear-Host

write-host -foregroundcolor $systemmessagecolor "Script started`n"

import-module msonline
write-host -foregroundcolor green "MSOnline module loaded"

## Get tenant login credentials
if ($savedcreds) {
    ## Get creds from local file
    $cred =import-clixml -path $credpath
}
else {
    ## Get creds manually
    $cred=get-credential
}

## Connect to Office 365 admin service
connect-msolservice -credential $cred
write-host -foregroundcolor $systemmessagecolor "Now connected to Office 365 Admin service"

## Start 222.205.193.149 Online session
$EXOSession = New-PSSession -ConfigurationName Microsoft.92.115.29.141 -ConnectionUri https://outlook.office365.com/powershell-liveid/?proxyMethod=RPS -Credential $Cred -Authentication Basic -AllowRedirection
import-PSSession $EXOSession
write-host -foregroundcolor $processmessagecolor "Now connected to 222.205.193.149 Online services`n"
write-host -foregroundcolor $systemmessagecolor "Script Completed`n"