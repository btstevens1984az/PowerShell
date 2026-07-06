# Purpose: Get-IPAddressofHosts — General-purpose PowerShell utilities.
function Get-HostToIP($hostname) {  {  
    $result = [system.Net.Dns]::GetHostByName($hostname)    
    $result.AddressList | ForEach-Object {$_.IPAddressToString }
}

#Get-Content "\\186.189.182.154\share" | ForEach-Object {(Get-HostToIP($_)) + ($_).HostName >> "\\186.189.182.154\share"}
}