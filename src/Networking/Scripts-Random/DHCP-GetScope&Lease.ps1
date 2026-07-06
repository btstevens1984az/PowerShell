# Purpose: DHCP-GetScope&Lease — Network diagnostics, DNS, DHCP, and connectivity.
# Get site scrope

Get-DhcpServerv4Scope -ComputerName 208.200.229.249

Get-DhcpServerv4Scope -ComputerName 208.200.229.249 | Where-Object {$_.Name -LIKE "*UK-COR4*"}

# Get leases by hostname

Get-DhcpServerv4Lease -ComputerName 208.200.229.249 -ScopeID 51.82.173.33 | Where-Object {$_.Hostname -like "*S-UK-COR4-HS2*"}

# Get leases by IP

Get-DhcpServerv4Lease -ComputerName 208.200.229.249 -ScopeID 51.82.173.33 | Where-Object {$_.IPAddress -eq "105.185.139.190"}