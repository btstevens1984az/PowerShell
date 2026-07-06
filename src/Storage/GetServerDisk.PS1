# Purpose: GetServerDisk — Storage management and disk operations.
                                                          
$objComputers = Get-Content Servers.txt
 foreach ($Computer in $objComputers) 
{ 
$wmi = gwmi -q "Select * from Win32_LogicalDisk Where DeviceID = 'C:'"                                                                
$Free = "{0:n0}" -f ($wmi.FreeSpace / 1mb)                                                                                            
$Size = "{0:n0}" -f ($wmi.Size / 1mb)  
$ComputerName = get-qadcomputer $computer -name                                                                                               
write-host $ComputerName                                                                                 
write-host "Total space (in Megabytes): $Size"    
write-host "Free space (in Megabytes): $free"                                                                              
}   