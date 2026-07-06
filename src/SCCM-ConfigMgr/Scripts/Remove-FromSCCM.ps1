# Purpose: Remove-FromSCCM — Configuration Manager collections and deployments.
<#	
	===========================================================================
     Created with: SAPIEN Technologies, Inc., PowerShell Studio 2012 v3.1.34
     Created on:   01/20/2018
	 Filename:     Remove-FromSCCM.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>
#Requires -version 3.0
param($NoExit)
if (!$NoExit)
{
	$Host.UI.RawUI.BackgroundColor = "Black"
	Clear-Host
	PowerShell -NoExit -File $MyInvocation.MyCommand.Path 1
	return
}
else
{
	$Computers = Read-Host -Prompt "Enter servers [seperated by a comma, if multiple] OR`nType `"file`" to point to a file with names OR`nJust press Enter to exit"
	if ($Computers -eq "") { exit }
	elseif ($Computers -eq "file")
	{
		[void][reflection.assembly]::LoadWithPartialName("System.Windows.Forms")
		$FileDialog = New-Object System.Windows.Forms.OpenFileDialog
		$FileDialog.Title = "Please select a file"
		$FileDialog.InitialDirectory = "U:\"
		$FileDialog.Filter = "Text files (*.txt)|*.txt"
		$Result = $FileDialog.ShowDialog()
		if ($Result -eq "OK")
		{
			$FilePath = $FileDialog.FileName
			$Computers = Get-Content $FilePath | ForEach-Object { $_.Trim() } | Where-Object { [String]::IsNullOrWhiteSpace($_) -eq $false }
		}
		else { exit }
	}
	else
	{
		$Computers = $Computers.Split(",").Trim()
	}
}

foreach ($Computer in $Computers) {
	$Obj = $null
	$Obj = Get-WmiObject -Class SMS_R_SYSTEM -Namespace root\sms\site_name -ComputerName "29.222.253.230" -Filter "Name = '$Computer'"
	if ($Obj -ne $null)
	{
		$DateIndex = $Obj.AgentName.IndexOf("Heartbeat Discovery")
		if ($DateIndex -eq -1) { $Date = "Unknown" }
		else { $Date = [System.Management.ManagementDateTimeConverter]::ToDateTime($Obj.AgentTime[$DateIndex]).ToShortDateString() }
		Write-Host -Object "$($Obj.Name) found in SCCM with OS $($Obj.operatingsystem). It last communicated with SCCM on $Date."
		if ($Host.Name -match "Console")
		{
			Write-Host "Delete? [y/n]"
			$Continue = [System.Console]::ReadKey($true)
			if ($Continue.Key -eq 'Y') { $Obj.Delete() }
		}
		else
		{
			Write-Host "Delete? [y/n]"
			$Continue = $Host.UI.ReadLine()
			if ($Continue -eq 'Y') { $Obj.Delete() }
		}
	}
	else
	{
		Write-Host -Object "$Computer was not found in SCCM"
	}
}