# Purpose: GetStatusAndStartService — Windows desktop configuration and management.
#GetStatusAndStartService.ps1
$computerName = "berlin"
$serviceName = "bits"
$remoteService = Get-Service -ComputerName $computerName -Name $serviceName
if($remoteService.status -ne 'running')
{
 $service = [wmi]"\\$computerName\root\cimv2:Win32_service.name=""$serviceName"""
    if($($service.startmode) -eq "disabled")
{
     $service.changeStartMode("manual")
     $service.startService()
    }
    ELSE
    {
     $service.startService()
    }
}
