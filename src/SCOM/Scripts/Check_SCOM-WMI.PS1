# Purpose: Check_SCOM-WMI — System Center Operations Manager monitoring.
<#	
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2014 v4.1.74
	 Created on:   	01/20/2018
	 Filename:     	Check_SCOM-WMI.ps1
     To-Do:         Change path below to your list of servers
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


write-Host "This script Checks the Status of the SCOM Service using WMI.  This will show the service startup information."
$Temp = Read-Host "Either enter a single server name or the name of a TXT file with a list of servers (No .TXT extension needed)"
$FileIn = $Temp+".TXT"

Write-Host $FileIn

$servers = $Temp

if (Test-Path $FileIn) {
  $servers = Get-Content $FileIn
  }


# setup the error logfile path
# change path to your preferred location for the error logs
$serverserrorlog = "C:\Scripts\reboot\Log\Reboot$($date)error.log"

$servers | ForEach-Object -process {
	# reassign the $_ varible to an easier to read variable for the rest of the script
	$server = $_
	# verify wmi connection
	if (Get-WmiObject -ComputerName $server -Class Win32_OperatingSystem) { 
		# This is where the code that does the work is to go
		
		Write-Host "*************"
		Write-Host $Server
		Get-WMIObject win32_service -filter "name = 'HealthService'" -computername $Server


	}
	# if wmi connetion fails log to file
	else {
		# and write it to the console
		Write-Host "could not make WMI connectiom  to $server" -foregroundcolor black -backgroundColor yellow
	}

}

Write-Host ""
Write-Host "Press Any key to continue..."

$HOST.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | OUT-NULL
$HOST.UI.RawUI.Flushinputbuffer()

