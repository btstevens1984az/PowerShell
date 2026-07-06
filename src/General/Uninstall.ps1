# Purpose: Uninstall — General-purpose PowerShell utilities.
<#
Now Micro Right Click Tools
#>

$ScriptName = $MyInvocation.MyCommand.path
$Directory = Split-Path $ScriptName

if ([string]::IsNullOrEmpty($Directory))
{
	$Directory = "C:\Program Files (x86)\Now Micro\Recast RCT"
	$ScriptName = "$Directory\install.ps1"
}

If(!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]"Administrator")){
	Start-Process Powershell.exe -ArgumentList "-STA -noprofile -file `"$ScriptName`"" -Verb RunAs
}
else {
		Get-Content "$Directory\Install Properties.ini" | ForEach-Object {
			$line = $_
			$SplitLine = $line.Split("=")
			if ($line.Contains("XMLPath")) {$XMLInstallLoc = $SplitLine[1]}
		}

		Get-ChildItem $XMLInstallLoc -Recurse -Filter ("*.xml") | ForEach-Object {
			$Filename = $_.Name
			if ($Filename.StartsWith("_Recast Enterprise")) {
				Remove-Item $_.FullName -Force -Recurse
			}
		}
		Get-ChildItem $Directory -Recurse | ForEach-Object {
			Remove-Item $_.FullName -Force -Recurse
		}
		Start-Sleep 1
		& cmd /c rd /s /q "`"$Directory`""
}