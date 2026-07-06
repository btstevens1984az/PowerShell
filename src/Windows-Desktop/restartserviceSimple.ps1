# Purpose: restartserviceSimple — Windows desktop configuration and management.
$computer = read-host "enter computer name"
If ($computer)
{
	$service =gwmi Win32_Service -ComputerName $computer -filter "name='spooler'"
	$rtn =$service.stopservice()
	If ($rtn.returnvalue -eq 0)
	{ Write-Host "Service stopped"}
	$rtn = $service.startservice()
	If ($rtn.returnvalue -eq 0)
	{ Write-Host "Service started"}
}