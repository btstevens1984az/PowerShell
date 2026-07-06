# Purpose: Get-ListeningUDPPorts — Network diagnostics, DNS, DHCP, and connectivity.
Function Get-ListeningUDPPorts {
(netstat -anop UDP).trim() | Select-Object -skip 2  | 
 ConvertFrom-String -PropertyNames "Proto","SrcIP","SrcPort","DstIP","DstPort","State","PID" -Delimiter '\s+|\:' | Format-Table -AutoSize -Wrap
 }