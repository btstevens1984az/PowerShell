<#
.SYNOPSIS
	Import an array of computer names from a text file, WMI query that array
	for the last user that logged onto the computer. Then based on switches
	used, generate a CSV or HTML report, or both.
.DESCRIPTION
	Queries a list of computers for last user logged in. Generates a report
	based on switches used. Must use at least 1 switch, either CSVReport, or
	HTMLRrport, or use both switches to produces both reports.
.PARAMETER CSVFile
	The location you want the CSVReport file to go.
.PARAMETER HTMLFile
	The location you want the HTMLReport file to go.
.PARAMETER Servers
	An array of computer names to be queried
.PARAMETER HTMLReport
	Switch to indicate you want an HTML report generated with the results of the queries.
.PARAMETER CSVReport
	Switch to indicate you want a CSV report generated with the results of the queries.
.EXAMPLE
	./Get-LastUserLoginTime.ps1 -CSVReport
.EXAMPLE
	./Get-LastUserLoginTime.ps1 -HTMLReport
.EXAMPLE
	./Get-LastUserLoginTime.ps1 -CSVReport -CSVFile "C:\Test\LastUsers.csv" -HTMLReport -HTMLFile "C:\Test\LastUsers.htm"
	Company:        Whidbey Telecom
	Spiceworks:     chamele0n
	Email:          Omitted
	
	Changelog:
		1.0         Initial release
.LINK
	http://community.spiceworks.com/scripts/show/2497-get-last-logon-user
.LINK
	http://community.spiceworks.com/topic/460923-get-last-logon-time-of-a-computer-powershell
#>

Param (
	[string]$CSVFile = "Output.csv",
	[string]$HTMLFile = "Output.htm",
	[array]$Servers = @(Get-Content "C:\Users\$env:USERNAME\Desktop\LegalHolds.txt"),
	[switch]$HTMLReport,
	[switch]$CSVReport
)

If ($HTMLReport -ne $True -and $CSVReport -ne $True)
{
	Write-Warning "No Switches were used, please use at least -HTMLReport or -CSVReport switch, to generate a report, or use both switches to generate both types of reports."
}
Else
{
	#Set variables
	$Results = @()

	#Loop through servers
	ForEach ($Server in $Servers)
	{
		Try
		{	Write-Host "Attempting to connect to $Server..."
			$LastUser = Get-WmiObject -ComputerName $Server -Query "SELECT LastUseTime,SID FROM Win32_UserProfile" -ErrorAction Stop | Sort-Object -Property LastUseTime -Descending | Select-Object -First 1
		}
		Catch
		{	$Results += New-Object PSObject -Property @{
				ComputerName = $Server
				ScriptUser = "Unknown"
				UserName = "Unknown"
				LoginTime = "Unknown"
				Status = "Unable to connect"
				ErrorMessage = $error[0]
			}
			Continue
		}
		$LoginTimeConverted = ([WMI]'').ConvertToDateTime($LastUser.LastUseTime) 
		# $SIDtoUser = (New-Object System.Security.Principal.SecurityIdentifier($LastUser.SID))
		$Results += New-Object PSObject -Property @{
			ComputerName = $Server
			ScriptUser = (Get-WmiObject Win32_ComputerSystem -ComputerName $Server).Username
			UserName = ""
			LoginTime = $LoginTimeConverted
			Status = "Connected"
			ErrorMessage = "None"
		}
		Try
		{	$UserName = (New-Object System.Security.Principal.SecurityIdentifier($LastUser.SID)).Translate([System.Security.Principal.NTAccount]).Value
			$Results[-1].UserName = $($UserName)
		}
		Catch
		{	Write-Host "Caught an error on host: $Server - $($Error[0])"
			$Results[-1].ErrorMessage = $error[0]
			$Results[-1].UserName = "Unknown"
		}
	}
	If ($HTMLReport)
	{
		### HTML Header	
		$Header = @"
	<center>
		<style>
			TABLE {border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;margin-left: auto;margin-right: auto;}
			TH {border-width: 1px;padding: 3px;border-style: solid;border-color: black;background-color: #808080;}
			TD {border-width: 1px;padding: 3px;border-style: solid;border-color: black;}
			.odd  { background-color:#ffffff; }
			.even { background-color:#dddddd; }
		</style>
	</center>
	<title>
		Last User Login Report
	</title>
"@
		$Results | Sort-Object Status,@{expression="LoginTime";Descending=$true} | ConvertTo-Html -Head $Header | Out-File $HTMLFile
	}
	If ($CSVReport)
	{
		$Results | Sort-Object Status,@{expression="LoginTime";Descending=$true} | Export-CSV $CSVFile -NoTypeInformation
	}
}