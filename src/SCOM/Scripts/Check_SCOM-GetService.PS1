# Purpose: Check_SCOM-GetService — System Center Operations Manager monitoring.
<#	
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2014 v4.1.74
	 Created on:   	01/20/2018
	 Filename:     	Check_SCOM-GetService.ps1
     To-Do:         Change path below to your list of servers
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


write-Host "This script uses the PS Cmdlet Get-Service to check the status of the SCOM Service.  It does NOT give the status of the service startup."
write-Host "It does show if the Service is not installed on the server"
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

 
	# This is where the code that does the work is to go
		
	Write-Host "*************"
	Write-Host $Server
	get-service -name healthservice -computername $Server

}


Write-Host ""
Write-Host "Press Any key to continue..."

$HOST.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | OUT-NULL
$HOST.UI.RawUI.Flushinputbuffer()