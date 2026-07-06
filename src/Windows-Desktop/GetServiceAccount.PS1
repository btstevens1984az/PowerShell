# Purpose: GetServiceAccount — Windows desktop configuration and management.


Set-ExecutionPolicy Unrestricted -Force
Set-ExecutionPolicy RemoteSigned -Force 

Write-Host "********************************"               -ForegroundColor Green

$SCRIPT_PARENT = Split-Path -Parent $MyInvocation.MyCommand.Definition
 

Function GetStatusCode
{ 
	Param([int] $StatusCode)  
	switch($StatusCode)
	{
		0 	{"Online"}
		11001   {"Buffer Too Small"}
		11002   {"Destination Net Unreachable"}
		11003   {"Destination Host Unreachable"}
		11004   {"Destination Protocol Unreachable"}
		11005   {"Destination Port Unreachable"}
		11006   {"No Resources"}
		11007   {"Bad Option"}
		11008   {"Hardware Error"}
		11009   {"Packet Too Big"}
		11010   {"Request Timed Out"}
		11011   {"Bad Request"}
		11012   {"Bad Route"}
		11013   {"TimeToLive Expired Transit"}
		11014   {"TimeToLive Expired Reassembly"}
		11015   {"Parameter Problem"}
		11016   {"Source Quench"}
		11017   {"Option Too Big"}
		11018   {"Bad Destination"}
		11032   {"Negotiating IPSEC"}
		11050   {"General Failure"}
		default {"Failed"}
	}
} 

 
$Result = @() 
 
$Servers = Get-Content ($SCRIPT_PARENT + "\Servers.txt")
#$Servers = Read-Host "Enter server name"
$outfile = ($SCRIPT_PARENT + "\ServiceAccounts_{0:yyyyMMdd-HHmm}.csv" -f (Get-Date))
  
Foreach ($Server in $servers) {

$i++
   Write-Progress -activity "Running....." -status "Count: $i of $($Servers.count)" -percentComplete (($i / $Servers.count) * 100)
      
$pingStatus = Get-WmiObject -Query "Select * from win32_PingStatus where Address='$Server'"
#$Ping =	Test-Connection -Quiet -ComputerName $server -Count 1

if($pingStatus.StatusCode -eq 0) {

$Resolve = [System.Net.Dns]::Resolve($server)
$FQDN = $Resolve.HostName

write-Host "Getting Service details from - ($Server)" -ForegroundColor Magenta

#$StandardServiceAccounts = "LocalSystem", "NT AUTHORITY\LocalService", "NT AUTHORITY\NetworkService"

$SrvcS = Get-WmiObject win32_service -ComputerName $Server #| Where-Object { $(($_.StartName -ne "LocalSystem") -or ($_.StartName -ne "NT AUTHORITY\LocalService"))}
#$SrvcS = Get-WmiObject win32_service -ComputerName $Server | Where-Object { $StandardServiceAccounts -ne $_.StartName }
# -or ($SrvcS.StartName -ne "NT AUTHORITY\LocalService"))


Foreach($Srvc in $SrvcS ) {
 
If(($Srvc.StartName -ne "LocalSystem") -and ($Srvc.StartName -ne "NT AUTHORITY\LocalService") -and ($Srvc.StartName -ne "NT AUTHORITY\NetworkService") ) {


$Result += New-Object PSObject -Property @{
	    ServerName = $Server
		FQDN = $FQDN
        Status = GetStatusCode( $pingStatus.StatusCode )
		Name = $Srvc.Name
		StartName = $Srvc.StartName
        StartMode = $Srvc.StartMode
		
	}
}
}
}
else { 

$Resolve = " "		
#$Resolve = [System.Net.Dns]::Resolve($server)
#if ($Resolve -ne ""){
$FQDN = $Resolve.HostName
	#	}
#-----------------------
write-Host "Server is not accessible - ($Server)" -ForegroundColor Red

$Result += New-Object PSObject -Property @{
	    ServerName = $Server
		FQDN = $FQDN
        Status = GetStatusCode( $pingStatus.StatusCode )
		Name = "NA"
		StartName = "NA"
        StartMode = "NA"


		}
}

$Result | select ServerName, FQDN, Status, Name, StartName, StartMode | Export-csv -NoTypeInformation -Path $OutFile -UseCulture


}
Invoke-Expression $OutFile 


#@================Code End=====================
