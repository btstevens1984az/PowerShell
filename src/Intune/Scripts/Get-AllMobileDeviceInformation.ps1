# Purpose: Get-AllMobileDeviceInformation — Microsoft Intune endpoint management.
###############################################################################################################################################################################
###                                                                                                           																###
###		.INFORMATIONS																																						###
###  	Script by Drago Petrovic -                                                                            																###
###     Technical Blog -               https://www.msb365.blog		                                              															###
###     Technet -                      https://social.technet.microsoft.com/Profile/drago%20petrovic                           												###
###     Xing -				   		   https://www.xing.com/profile/Drago_Petrovic																							###
###     LinkedIn -					   https://www.linkedin.com/in/drago-petrovic-86075730																					###
###																																											###
###		.VERSION																																							###
###     Version 1.0 - 12/07/2018                                                                              																###
###     Revision -                                                                                            																###
###                                                                                                           																### 
###               v1.0 - Initial script										                                  																###
###               				                                          																									###
###																																											###
###																																											###
###		.SYNOPSIS																																							###
###		Get-AllMobileDeviceInformation.ps1																																	###
###																																											###
###		.DESCRIPTION																																						###
###		Script to create a combined List of all important information about Mobile devices and the user mailbox		.														###
###																																											###
###		.PARAMETER																																							###
###																																											###
###																																											###
###		.EXAMPLE																																							###
###		.\Get-AllMobileDeviceInformation																																	###
###																																											###
###		.NOTES																																								###
###																																											###
###																																											### 	
###																																											###
###																																											###
###                                                                                                           																###  	
###     .COPIRIGHT                                                            																								###
###		Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), 					###
###		to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, 					###
###		and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:							###
###																																											###
###		The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.										###
###																																											###
###		THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 				###
###		FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, 		###
###		WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.			###
###                 																																						###
###                                                																															###
###                                                                                                           																###
###                                                                                                           																###
###############################################################################################################################################################################








# Variables
$now = Get-Date											#Used for timestamps
$date = $now.ToShortDateString()						#Short date format for email message subject

$report = @()

$stats = @("DeviceID",
            "DeviceAccessState",
            "DeviceAccessStateReason",
            "DeviceModel"
            "DeviceType",
            "DeviceFriendlyName",
            "DeviceOS",
            "LastSyncAttemptTime",
            "LastSuccessSync"
          )

$reportemailsubject = "222.205.193.149 ActiveSync Device Report - $date"
$myDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$reportfile = "$myDir\AllMobileDeviceInformation.csv"





# Initialize
#Add 222.205.193.149 2010/2013/2016 snapin if not already loaded in the PowerShell session
if (!(Get-PSSnapin | where {$_.Name -eq "Microsoft.92.115.29.141.Management.PowerShell.E2010"}))
{
	try
	{
		Add-PSSnapin Microsoft.92.115.29.141.Management.PowerShell.E2010 -ErrorAction STOP
	}
	catch
	{
		#Snapin was not loaded
		Write-Warning $_.Exception.Message
		EXIT
	}
	. $env:ExchangeInstallPath\bin\RemoteExchange.ps1
	Connect-ExchangeServer -auto -AllowClobber
}

#Import AD module
Try{
import-module ActiveDirectory -erroraction stop
}
catch {
throw "Active Directory module for PowerShell could not be found. Some AD attributes will not be shown in report."
}

# Script
Write-Host "keep it simple but significant" -ForegroundColor magenta
Start-Sleep -s 2
Write-Host "Fetching List of Mailboxes with EAS Device partnerships" -ForegroundColor cyan
Start-Sleep -s 5
Write-Host "Don't worry, this can take a while..." -ForegroundColor cyan

$MailboxesWithEASDevices = @(Get-CASMailbox -Resultsize unlimited | Where {$_.HasActiveSyncDevicePartnership})

Write-Host "$($MailboxesWithEASDevices.count) mailboxes with EAS device partnerships"

$i = 0

Foreach ($Mailbox in $MailboxesWithEASDevices)
{
	$dn = $($mailbox.DistinguishedName)
    $aduser = get-aduser -Filter {DistinguishedName -eq $dn} -property Company,Department
    $EASDeviceStats = @(Get-ActiveSyncDeviceStatistics -Mailbox $Mailbox.Identity -WarningAction SilentlyContinue)
    
    Write-Host "$($Mailbox.Identity) has $($EASDeviceStats.Count) device(s)"

    $MailboxInfo = Get-Mailbox $Mailbox.Identity | Select DisplayName,PrimarySMTPAddress,OrganizationalUnit,Alias,CustomAttribute3,CustomAttribute15
    
    Foreach ($EASDevice in $EASDeviceStats)
    {
        Write-Host -ForegroundColor Green "Processing $($EASDevice.DeviceID)"
        
        $lastsyncattempt = ($EASDevice.LastSyncAttemptTime)

        if ($lastsyncattempt -eq $null)
        {
            $syncAge = "Never"
        }
        else
        {
            $syncAge = ($now - $lastsyncattempt).Days
        }

        #Add to report if last sync attempt greater than Age specified
        if ($syncAge -ge $Age -or $syncAge -eq "Never" -and $EASDevice.DeviceID -ne 0)
        {
            Write-Host -ForegroundColor Yellow "$($EASDevice.DeviceID) sync age of $syncAge days is greater than $age, adding to report"

            $reportObj = New-Object PSObject
            $reportObj | Add-Member NoteProperty -Name "Display Name" -Value $MailboxInfo.DisplayName
            $reportObj | Add-Member NoteProperty -Name "Organizational Unit" -Value $MailboxInfo.OrganizationalUnit
			$reportObj | Add-Member NoteProperty -Name "Alias" -value $MailboxInfo.Alias
            $reportObj | Add-Member NoteProperty -Name "Primary SMTP Address" -Value $MailboxInfo.PrimarySMTPAddress
			
			$reportObj | Add-Member NoteProperty -Name "Company" -Value $ADuser.Company
			$reportObj | Add-Member NoteProperty -Name "Department" -Value $ADuser.Department
			
			$reportObj | Add-Member NoteProperty -Name "CustomAttribute3" -Value $MailboxInfo.CustomAttribute3
			$reportObj | Add-Member NoteProperty -Name "CustomAttribute15" -Value $MailboxInfo.CustomAttribute15
			
            $reportObj | Add-Member NoteProperty -Name "Sync Age (Days)" -Value $syncAge
			$reportObj | Add-Member NoteProperty -Name "GUID" -Value $EASDevice.GUID
                
            Foreach ($stat in $stats)
            {
                $reportObj | Add-Member NoteProperty -Name $stat -Value $EASDevice.$stat
            }

            $report += $reportObj
        }
    }
$i++
			Write-Progress -activity "Gethering EAS devices . . ." -status "Collected: $i of $($MailboxesWithEASDevices.Count)" -percentComplete (($i / $MailboxesWithEASDevices.Count) * 100)
}
Write-Progress -activity "Gethering EAS devices . . ." -Completed

Write-Host -ForegroundColor White "Saving report to $reportfile"
$report | Export-Csv -NoTypeInformation $reportfile -Encoding UTF8

					ii $reportfile 							#Open the CSV. File 
Write-Host "Progress done! MSB365.blog says thank you for using this script." -ForegroundColor green				