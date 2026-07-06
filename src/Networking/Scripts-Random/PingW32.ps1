# Purpose: PingW32 — Network diagnostics, DNS, DHCP, and connectivity.
# PowerShell 2
# kerry
# Win32_PingStatus 
# PingW32.PS1
$i =1
$Ip = "10.6.36."
Write-Host "IP Address"
Write-Host "----------------------------------------"
Do { $Ip4th = $Ip + $i
$Pingy = Get-WmiObject Win32_PingStatus -f "Address='$Ip4th'"
if($Pingy.StatusCode -eq 0) {
     "{0,0} {1,5} {2,5}" -f
     $Pingy.Address, $Pingy.StatusCode," ON NETWORK"}
     else
     {"{0,0} {1,5} {2,5}" -f $Pingy.Address, $Pingy.StatusCode, " YS"
     }
$i++
}
until ($i -eq 255)