# Purpose: getwineventHash — General-purpose PowerShell utilities.
$hash = @{
	logname="Microsoft-Windows-Diagnostics-Performance/Operational";
	id=302;
}

$events = Get-WinEvent -FilterHashtable $hash