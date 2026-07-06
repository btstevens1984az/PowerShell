# Purpose: Get-DHCPInfo2CSV — Network diagnostics, DNS, DHCP, and connectivity.
#get dhcp info
# Set server  IP of DHCP server to query

#  ccal-dhcp-02-n1  ccal-dhcp  chw-dhcp-001 lvspvdhcp001  114.148.18.125 sacpvdhcp001 sbmpvdhcp001  
#   scal-dhcp-001  scal-dhcp chw-dhcp

$Scopes = netsh dhcp server 242.97.157.204 show scope
$LeaseReport = @()
foreach ($Scope in $Scopes)
    {
    $Leases = (netsh dhcp server 242.97.157.204 scope $Scope.split("-")[0].trim() show clients 1) | Select-String "-D-" 
    
    foreach ($Lease in $Leases) 
        {
        If ($Lease -notmatch "NEVER EXPIRES")
            {
            $Info = New-Object -type System.Object
            $Hostname = $Lease.tostring().replace("-D-",";").Split(";").Trim()
            $Info | Add-Member -MemberType NoteProperty -name Hostname -Value $Hostname[1]
            $IP = $Hostname[0].replace(" - ",";").Split(";") 
            $Info | Add-Member -MemberType NoteProperty -name IPAddress -Value $IP[0]
            $Info | Add-Member -MemberType NoteProperty -name SubnetMask -Value $IP[1]
            $Info | Add-Member -MemberType NoteProperty -name MACAddress -Value $IP[2].replace(" -",";").Split(";")[0].Trim()
            $LeaseReport += $Info
            $Info | ft -AutoSize
            }
        }

    }
$LeaseReport | export-csv "c:\temp\dhcpInfo $ServerItem.csv"