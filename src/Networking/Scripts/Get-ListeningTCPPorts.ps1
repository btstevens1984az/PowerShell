# Purpose: Get-ListeningTCPPorts — Network diagnostics, DNS, DHCP, and connectivity.
Function Get-ListeningTCPPorts {
(netstat -anop TCP).trim() | Select-Object -skip 2  | 
 ConvertFrom-String -PropertyNames "Proto","SrcIP","SrcPort","DstIP","DstPort","State","PID" -Delimiter '\s+|\:' | Format-Table -AutoSize -Wrap
 }