# Purpose: InLineGetIPDemo — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE: 2/8/2009
#
# KEYWORDS: Inlline code demo, IP networking,
# Win32_NetworkAdapterConfiguration
# COMMENTS: This script retrieves basic IP netwrok
# information. 
#
#
# MSPRESS: Microsoft PowerShell Best Practice
# ------------------------------------------------------------------------
$IP = Get-WmiObject -class Win32_NetworkAdapterConfiguration -Filter "IPEnabled = $true"
"IP Address: " + $IP.IPAddress[0]
"Subnet: " + $IP.IPSubNet[0]
"GateWay: " + $IP.DefaultIPGateway
"DNS Server: " + $IP.DNSServerSearchOrder[0]
"FQDN: " + $IP.DNSHostName + "." + $IP.DNSDomain