# Purpose: Install KB2871997 W7 wReg — General-purpose PowerShell utilities.
<#	
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2015 v4.2.82
	 Created on:   	8/11/2016
	 Filename:     	Install_KB2871997_wReg.ps1
	===========================================================================
	.DESCRIPTION
		KB to disable clear text session credentials
#>
$ErrorActionPreference = "SilentlyContinue"
$env:SEE_MASK_NOZONECHECKS = 1
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$wshShell = new-object -comobject wscript.shell
$strDate = Get-Date -Format d

#-----OS & bit
$kbName = "Windows6.1-KB2871997-v2-"

$osBit = (Get-WmiObject Win32_OperatingSystem).OSArchitecture
if ($osBIT -eq "64-bit") { $kbBit = "x64" }
else { $kbBit = "x86" }

#-----Check for KB
$hotFixID = "KB2871997"
$hotFix = Get-HotFix | Where-Object { $_.HotFixId -eq $hotFixID } | Select-Object -First 1;
if ($hotFix -eq $null)
{
	$runProcess = Start-Process -FilePath "$scriptPath\$kbName$kbBit.msu" -ArgumentList "/quiet /norestart" -PassThru
	Wait-Process -InputObject $runProcess
	
	$strKB = "KB Installed"
}
else { $strKB = "Already Installed" }

#-----Reg Entry
$runReg = Start-Process -FilePath regedit -ArgumentList "/s", "$scriptPath\UseLogonCredential.reg" -PassThru
Wait-Process -InputObject $runReg

$reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $env:COMPUTERNAME)
$regKey = $reg.OpenSubKey("SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest")
$regExist = $regKey.GetValue("UseLogonCredential")

If ($regExist -eq "00000000") { $strReg = "Reg Success" }
else
{
	$strReg = "Reg Failed"
	Exit (0)
}

#-----Reboot check
if (($env:COMPUTERNAME.Contains("CRI")) -or (Test-Path "C:\724Access"))
{
	Exit (0)
}
#-----Logged on or not
$getUser = Get-Process explorer -ErrorAction SilentlyContinue
if ($getUser -eq $null)
{
	#Restart
	Restart-Computer 131.230.190.167
}
else
{
	#Prompt
	Start-Process -FilePath "$scriptPath\RestartPrompt.exe"
}