# Purpose: Get-RestartEvents — General-purpose PowerShell utilities.
#####################################################################################################################################################
# Script to find out last reboot event from list of servers in servers.txt, it searchesin System Events on servers and looks for event id 1074:     #
# Prints ServerName, Time when the Event got created, Event ID, Event Severity and the message which contains user name who initiated the reboot:   #
# To get the output in CSV file just replace "|Out-Gridview" at the fourth last line with "| Export-Csv -NoTypeInformation ServerRebootEvents.csv": #
# This script only queries the event logs and does not perform any write/modification anywhere on the servers, Use it at your own wish.             #
# Written by Prakash Kumar Prakash82x@gmail.com on Thursday, March 9, 2017 11:48:55 AM                                                              #
#####################################################################################################################################################

$ErrorServers = @()
$checksystems = Get-Content C:\tempDev\FSSServers.txt
foreach ($Server in $checkSystems) {

# Foreach ($Server in $CheckSystems) {$Server; Get-WinEvent -ListLog "Windows PowerShell" -Computername $Server}
	#$check = $computername
	#Get-WinEvent -computername $Check -FilterHashtable @{logname="System";id="1074"} -MaxEvents 1 |select @{N='ServerName';E={"$ComputerName"}},TimeCreated,Id,LevelDisplayName,Message |FT
        
		$Server; Get-WinEvent -Computername $Server -FilterHashtable @{logname="System";id="1074"} -MaxEvents 1 |select @{N='ServerName';E={"$ComputerName"}},TimeCreated,Id,LevelDisplayName,Message |FT
		 
		 Write-Host -foregroundcolor Yellow $Server processed
		 
		 
		 
		 }
    

Write-Host " "

