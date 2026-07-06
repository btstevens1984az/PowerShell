# Purpose: pingYS — Network diagnostics, DNS, DHCP, and connectivity.
# $ping = New-Object System.Net.NetworkInformation.Ping 
# $i = 0 
# 1..255 | foreach { $ip = "10.6.36.$_"  
# $Res = $ping.send($ip) 
#  
# if ($Res.Status -eq "Success") 
# { 
#  
# $result = $ip + " = Success" 
# Write-Host $result 
#  
# $i++ 
#  
# } 
#  
#  
# }  