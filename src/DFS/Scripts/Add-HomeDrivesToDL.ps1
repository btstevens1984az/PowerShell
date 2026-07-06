# Purpose: Add-HomeDrivesToDL — PowerShell automation.
<#	
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2014 v4.1.74
	 Created on:   	01/20/2018
	 Filename:     	Add-HDrivesToDL.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>
#Requires -version 3.0
param ($NoExit)

# restart PowerShell with -noexit, the same script, and 1
if (!$NoExit)
{
	$Host.UI.RawUI.BackgroundColor = "Black"
	Clear-Host
	PowerShell -NoExit -File $MyInvocation.MyCommand.Path 1
	return
}

try
{
	Import-Module ActiveDirectory -ErrorAction 'Stop'
}
catch
{
	throw "Unable to load AD module. $($_.Exception.Message)"
}

[String]$Share = (Read-Host -Prompt "Enter user share to build DL from [e.g. \\46.124.38.189\UserFolder1]").TrimEnd("\")
if ((Test-Path $Share) -eq $false)
{
	throw "$Share does not exist."
}

$Users = New-Object System.Collections.ArrayList
$Errors = New-Object System.Collections.ArrayList

$Directories = [System.IO.Directory]::GetDirectories($Share)
Write-Host -Object "$($Directories.Count) directories found in $Share"
foreach ($Directory in $Directories)
{
	$UserObj = $null
	$User = $Directory.Split("\")[-1]
	try
	{
		$UserObj = Get-ADUser -Identity $User -ErrorAction 'Stop'
	}
	catch
	{
		[void]$Errors.Add("$User")
		continue
	}
	finally
	{
		if ($UserObj -ne $null) { [void]$Users.Add($UserObj.DistinguishedName) }
	}
}
$Log = "$env:USERPROFILE\Desktop\DLUpdateError_$(Get-Date -Format MMddyyyy_HHmm).txt"
[System.IO.File]::WriteAllLines($Log, $Errors)
Set-ADGroup -Identity 'AC Folder Migration List A' -Replace @{ member = [string[]]$Users } -Confirm
Write-Host -Object "$($Users.Count) successfully added to group"
Write-Host -Object "$($Errors.Count) not able to be added to the group because they could not be located in AD.`nSee log at $Log for full list"