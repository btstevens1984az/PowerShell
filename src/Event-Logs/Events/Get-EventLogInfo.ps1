# Purpose: Get-EventLogInfo — Windows event log querying and analysis.
<#	
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2017
	 Created on:   	01/21/2018 12:51 PM
	 Filename:     	Get-FSRMFileScreenEvents.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>
#Requires -version 3.0
#Import-Module ActiveDirectory
#$OU = "OU=Domain Controllers,DC=CHW,DC=EDU"
#$OU = "OU=Servers,OU=AZ,DC=CHW,DC=EDU"
#$Servers = Get-ADComputer -SearchBase $OU -SearchScope 'Subtree' -Filter { OperatingSystem -like "*Windows*Server*" } | Select-Object -ExpandProperty Name
$Servers = Get-Content C:\Temp\AllDH.txt | ForEach-Object { $_.Trim() } | Where-Object { [String]::IsNullOrWhiteSpace($_) -eq $false } | Select-Object -Unique
$AllServerInfo = New-Object System.Collections.ArrayList
foreach ($Server in $Servers) {
	$Session = New-Object System.Diagnostics.Eventing.Reader.EventLogSession -ArgumentList $Server
	$XMLQuery = "*[System[(EventID='104')]]"
	$Query = New-Object System.Diagnostics.Eventing.Reader.EventLogQuery -ArgumentList System, LogName, $XMLQuery
	$Query.Session = $Session
	try {
		$LogReader = New-Object System.Diagnostics.Eventing.Reader.EventLogReader -ArgumentList $Query
	}
	catch {
		$ServerInfo = New-Object PSObject -Property ([ordered]@{
				Server = $Server
				EventID = $($_.Exception.InnerException.Message.Replace("`n","").Replace(",",""))
				TimeCreated = ""
				TaskDisplayName = ""
				UserId = ""
				ProcessId = ""
				ThreadId = ""
			})
		$AllServerInfo.Add($ServerInfo)
		continue
	}
	for ($CurrentEvent = $LogReader.ReadEvent(); $CurrentEvent -ne $null; $CurrentEvent = $LogReader.ReadEvent()) {
		Write-Host $Server
		Write-Host $CurrentEvent.TimeCreated
		$ServerInfo = New-Object PSObject -Property ([ordered]@{
				Server = $Server
				EventID = $CurrentEvent.Id
				TimeCreated = $CurrentEvent.TimeCreated
				TaskDisplayName = $CurrentEvent.TaskDisplayName
				UserId = $CurrentEvent.UserId
				ProcessId = $CurrentEvent.ProcessId
				ThreadId = $CurrentEvent.ThreadId
			})
		$AllServerInfo.Add($ServerInfo)
	}
}
$CSV = $AllServerInfo | Sort-Object TimeCreated -Descending | ConvertTo-Csv -NoTypeInformation
$Date = Get-Date -Format MMddyyyy_HHmm
$FilePath = $env:USERPROFILE + "\Desktop\" + "EventClear_" + $Date + ".csv"
[System.IO.File]::WriteAllLines($FilePath, $CSV)
#Invoke-Item $FilePath
