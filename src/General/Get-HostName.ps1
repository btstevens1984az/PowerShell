# Purpose: Get-HostName — General-purpose PowerShell utilities.
# Script to input list of IP addresses and return IP/Hostname
#Kerry Kreitinger
# August 17, 2017

$ErrorActionPreference = "SilentlyContinue"
# Set-ExecutionPolicy remotesigned -Force $ErrorActionPreference



$OutputPath = "C:\PSReports\"

$OutputNameTxt = "C:\PSReports\MachineNames.txt"
Write-host Path to results file $OutputNameTxt
Remove-Item -path $OutputNameTxt -Force

Get-Content C:\temp\ips.txt | ForEach-Object{
$hostname = ([System.Net.Dns]::GetHostByAddress($_)).Hostname
if($? -eq $True) {
  $_ +","+ $hostname >> $OutputNameTxt
  
Get-NetIPAddress -CimSession $hostname -AddressFamily IPv4 | 
where { $_.InterfaceAlias -notmatch 'Loopback'} |
Select PSComputername,IPAddress | write-host
  
}
else {
   $_ +",FAILED" >> $OutputNameTxt
   
}

	}
