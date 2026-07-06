# Purpose: PingRange — Network diagnostics, DNS, DHCP, and connectivity.
# PowerShell Win32_PingStatus
$i =1
$Ip = "10.6.36."
Write-Host "IP Address"
Write-Host "----------------------------------------"
Do { $Ip4th = $Ip + $i
$Pingy = Get-WmiObject Win32_PingStatus -f "Address='$Ip4th'"
if($Pingy.StatusCode -eq 0) {
     "{0,0} {1,5} {2,5}" -f
     $Pingy.Address | export-csv c:\pingy.csv} 
     else 
     {"{0,0} {1,5} {2,5}" -f $Pingy.Address, $Pingy.StatusCode, " nonresponsive"
     }
$i++
}
until ($i -eq 120)
