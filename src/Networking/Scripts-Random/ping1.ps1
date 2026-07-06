# Purpose: ping1 — Network diagnostics, DNS, DHCP, and connectivity.
while (1) {
Start-Sleep -Seconds 2
if ($Result -eq $false) {get-date | out-file c:\temp\test-connection.txt}
}

