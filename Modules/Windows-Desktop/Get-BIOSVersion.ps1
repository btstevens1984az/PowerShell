# Purpose: Get-BIOSVersion — Windows desktop configuration and management.
function Get-BIOSDetails {            
param($Computer)            

$output = "" | select ComputerName, BIOSVersion, SerialNumber            
$obj = Get-WMIObject -Class Win32_BIOS -ComputerName $Computer             
$output.ComputerName = $Computer.ToUpper()            
$output.BIOSVersion = $obj.SMBIOSBIOSVersion            
$output.SerialNumber = $obj.SerialNumber            

$output            

}