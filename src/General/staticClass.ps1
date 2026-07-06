# Purpose: staticClass — General-purpose PowerShell utilities.
#using static .net classes
$DNSName = Read-Host "What name would you like me to resolve"
$Result = [system.net.dns]::GetHostAddresses($DNSName)
$result