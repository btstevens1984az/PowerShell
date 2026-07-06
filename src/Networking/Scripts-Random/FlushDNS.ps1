# Purpose: FlushDNS — Network diagnostics, DNS, DHCP, and connectivity.
function FlushDNS ()
{
	Write-Host "Flushing DNS..." -ForegroundColor Yellow;
	Clear-DnsClientCache
	Write-Host "DNS Flush completed." -ForegroundColor Green
}