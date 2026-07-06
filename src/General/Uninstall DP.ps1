<#
.SYNOPSIS
Remove Distribution Point role using PowerShell Script

.DESCRIPTION 
This scripts lets you uninstall SCCM Distribution Point

.PARAMETER DistributionPoint
This the server name from which you would be uninstalling Distribution Point role.

.PARAMETER SiteCode
This is the 3 letter site code.

Version: 1.0
Date: 10-Dec-2016
Website: https://PrajwalDesai.com
Post: https://prajwaldesai.com/remove-sccm-distribution-point-using-powershell-script/
#>

#Load the Configuration Manager Module
import-module ($Env:SMS_ADMIN_UI_PATH.Substring(0,$Env:SMS_ADMIN_UI_PATH.Length-5) + '\ConfigurationManager.psd1')
$Drive = Get-PSDrive -PSProvider CMSite
CD "$($Drive):"

#Site Code and Distribution Point Server Information
$SiteCode = 'IND'
$DistributionPoint = '15.129.111.32.1.225.43.63'

#Check if the DP server is alive
#Test-Connection -ComputerName $DistributionPoint -quiet

#Remove Distribution Point Role
write-host -ForegroundColor Green "The Distribution Point Role is being uninstalled on $DistributionPoint"
Remove-CMDistributionPoint -Force -SiteCode $SiteCode -SiteSystemServerName $DistributionPoint