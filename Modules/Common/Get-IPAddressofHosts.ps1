# Purpose: Get-IPAddressofHosts — Reusable PowerShell function libraries.
function Get-HostToIP($hostname) {  {  
    $result = [system.Net.Dns]::GetHostByName($hostname)    
    $result.AddressList | ForEach-Object {$_.IPAddressToString }
}

#Get-Content "C:\Users\$env:USERNAME\Desktop\05162018.txt" | ForEach-Object {(Get-HostToIP($_)) + ($_).HostName >> "C:\Users\$env:USERNAME\Desktop\05162018ips.txt"}
}