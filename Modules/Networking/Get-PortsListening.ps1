# Purpose: Get-PortsListening — Network diagnostics, DNS, DHCP, and connectivity.
Function Get-PortsListening {
([Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties()).GetActiveTcpListeners() 
}