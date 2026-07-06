# Purpose: Ping-MultipleHosts — Network diagnostics, DNS, DHCP, and connectivity.
Function Ping-MultipleHosts {

$servers = Get-Content "C:\Users\$env:USERNAME\Desktop\HPCADesktop.txt"
$ping = New-Object System.Net.NetworkInformation.Ping
 
    foreach($s in $servers)
    {
        $("$s,$($ping.Send($s).Address)")
    }
}