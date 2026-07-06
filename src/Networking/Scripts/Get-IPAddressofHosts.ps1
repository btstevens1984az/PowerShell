# Purpose: Get-IPAddressofHosts — Network diagnostics, DNS, DHCP, and connectivity.
﻿#========================================================================
# Filename:     Get-IPAddressofHosts.ps1
function Get-HostToIP($hostname) {    
    $result = [system.Net.Dns]::GetHostByName($hostname)    
    $result.AddressList | ForEach-Object {$_.IPAddressToString }
}

Get-Content "C:\Temp\Servers.txt" | ForEach-Object {(Get-HostToIP($_)) + ($_).HostName >> C:\Temp\Addresses.txt}