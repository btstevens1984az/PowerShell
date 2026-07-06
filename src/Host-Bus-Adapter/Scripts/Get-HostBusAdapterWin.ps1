# Purpose: Get-HostBusAdapterWin — PowerShell automation.
function Get-HostBusAdapterWin {  
param($ComputerName)
  
$ComputerName | ForEach-Object {  
$Computer = $_
$Namespace = "root\WMI"
Get-WmiObject -class MSFC_FCAdapterHBAAttributes -computername $Computer -namespace $namespace |  
ForEach-Object {  
$hash=@{  
ComputerName     = $_.__SERVER  
NodeWWN          = (($_.NodeWWN) | ForEach-Object {"{0:x2}" -f $_}) -join ":"  
Active           = $_.Active  
DriverName       = $_.DriverName  
DriverVersion    = $_.DriverVersion  
FirmwareVersion  = $_.FirmwareVersion  
Model            = $_.Model  
ModelDescription = $_.ModelDescription  
}  
New-Object psobject -Property $hash  
}
} 
}

function Get-WWNs {
	param($ComputerName)
	$ComputerName | ForEach-Object {
		$Computer = $_
		Get-WmiObject -class MSFC_FibrePortHBAAttributes -computername $Computer -namespace Root\WMI |
			ForEach-Object {
			$hash=@{  
			ComputerName     = $_.__SERVER  
			NodeWWN          = (($_.Attributes.NodeWWN) | ForEach-Object {"{0:x2}" -f $_}) -join ":"
			PortWWN          = (($_.Attributes.PortWWN) | ForEach-Object {"{0:x2}" -f $_}) -join ":"  
			}
		New-Object psobject -Property $hash  
		}
	}
}

[String[]]$Servers = read-host -Prompt "Enter server names, seperated by commas (quotes not required)"
$Servers = $Servers.Split(",").Trim()
#$HBAInfo = Get-HBAWin $Servers
$HBAInfo = Get-WWNs $Servers
Write-Output $HBAInfo
$HBAInfo | Format-Table ComputerName,NodeWWN,PortWWN -AutoSize
pause
