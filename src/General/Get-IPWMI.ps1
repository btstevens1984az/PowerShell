# Purpose: Get-IPWMI — General-purpose PowerShell utilities.
# wmi query for IP
# where { (($_.IPEnabled -ne $null) -and ($_.DefaultIPGateway -ne $null)) } 

(Get-WmiObject win32_Networkadapterconfiguration | Where-Object{$_.ipaddress -notlike $null}).IPaddress | Select-Object -First 1

Get-WmiObject win32_Networkadapterconfiguration |where { (($_.IPEnabled -ne $null) -and ($_.DefaultIPGateway -ne $null)) } | Select-Object -Property PSComputername, IPAddress

# Get-Content C:\temp\IPs.txt | ForEach-Object {([system.net.dns]::GetHostByAddress($_)).hostname >> c:\temp\resultstest.txt