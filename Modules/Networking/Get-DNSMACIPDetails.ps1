# Purpose: Get-DNSMACIPDetails — Network diagnostics, DNS, DHCP, and connectivity.
Function Get-DNSMACIPDetails {
$computers= gc U:\Functions\AllSatelliteServers.txt 

Remove-Item -Path "c:\Temp\dns.csv" 
 
foreach ($computer in $computers) 
{ 
$computer 
$error.clear() 
$twist="" 
$a="" 
try 
{ 
$a=Get-WmiObject Win32_NetworkAdapterConfiguration -ComputerName $computer -EA Stop | ? {$_.IPEnabled}  | select DNSHostName,MACAddress,ServiceName,IPSubnet,DefaultIPGateway,IPAddress,DNSServerSearchOrder,Description,DNSDomainSuffixSearchOrder -ErrorAction Continue 
$cn=$computer 
$mac=$a.MACAddress 
$ipsub=$a.IPSubnet[0] 
$nat=$a.IPSubnet[1] 
$ipgate=$a.DefaultIPGateway[0] 
$ipv4=$a.IPAddress[0] 
$ipv6=$a.IPAddress[1] 
$pri=$a.DNSServerSearchOrder[0] 
$sec=$a.DNSServerSearchOrder[1] 
$isVM=$a.Description 
if($a.DNSDomainSuffixSearchOrder -like "") 
{ 
$dns="Unable to locate Domain" 
} 
else 
{ 
$dns=$a.DNSDomainSuffixSearchOrder[0] 
} 
} 
catch 
{ 
[string]$twist=$error 
$cn=$computer 
$mac=$ipsub=$nat=$ipgate=$ipv4=$ipv6=$pri=$sec=$isVM=$dns=$twist 
   
}   
     
    $obj = New-Object -TypeName PSObject -Property @{'ComputerName'=$cn;'MACaddress'=$mac;'IPV4'= $ipv4;'Ipv6_autoassigned'= $ipv6;'Subnet'= $ipsub;'CIDR'=$nat;'PrimaryDNS'= $pri;'SecondaryDNS'= $Sec;'Gateway'= $ipgate;'ServerType'= $isVM;'DNSDomain'= $dns} 
    $obj | select ComputerName,MACaddress,IPV4,Ipv6_autoassigned,Subnet,CIDR,PrimaryDNS,SecondaryDNS,Gateway,ServerType,DNSDomain|Export-CSV -Append -Path "c:\temp\onlyc.csv" 
} 
Get-Content "c:\temp\Dns.csv"  | ConvertFrom-Csv | Out-GridView -Title "Servers with IP address List - DNS" 
}