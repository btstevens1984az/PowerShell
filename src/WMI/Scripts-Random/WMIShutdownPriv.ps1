# Purpose: WMIShutdownPriv — PowerShell automation.
#JD
$computer = "78.61.6.96"
$OS = Get-WmiObject win32_operatingsystem -computer	$computer
$OS.psbase.scope.options.EnablePrivileges = $true
$result = $OS.shutdown()
