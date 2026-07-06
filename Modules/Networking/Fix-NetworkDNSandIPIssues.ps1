# Purpose: Fix-NetworkDNSandIPIssues — Network diagnostics, DNS, DHCP, and connectivity.
Function Fix-NetworkDNSandIPIssues {
#+-------------------------------------------------------------------+
#| = : = : = : = : = : = : = : = : = : = : = : = : = : = : = : = : = |  
#|{>/-------------------------------------------------------------\<}|           
#|: | Author:  Brandon Stevens                                    | :|           
#|: | Purpose: Flush IP address, renew it , Flush DNS, Register DNS     
#|: |                    Date: 30-May-2018       
#| :|
#| :|
#| :| 	/^(o.o)^\    	 Version: 1        						  |: | 
#|{>\-------------------------------------------------------------/<}|
#| = : = : = : = : = : = : = : = : = : = : = : = : = : = : = : = : = | #+-------------------------------------------------------------------+

# Date 30-May-2018

# Funcationality : Flush DNS , Release IP Address | Register Ip Address | Register DNS 

# Flush the DNS Cache
ipconfig /flushDns | Out-Null
Write-Host "DNS Cache Flushed" -ForegroundColor Green

# Release the Ip-AdDress

ipconfig /release | Out-Null
Write-Host  "Ip-Adresses flushed; Now renewing the Ip-Address" -ForegroundColor Green

# Sleep for 4 Seconds

sleep 4

# Renew the Ip-Address

ipconfig /renew | Out-Null
Write-Host "Ip-Address Renewed" -ForegroundColor Green


# Register the DNS
ipconfig /registerdns | Out-Null
Write-Host "DNS Regsitered" -ForegroundColor Green
}