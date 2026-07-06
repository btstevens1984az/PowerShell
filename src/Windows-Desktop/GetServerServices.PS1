# Purpose: GetServerServices — Windows desktop configuration and management.
# gwmi win32_service | where {$_.StartName -eq "adc_admin"} | select name,startname                                                          
$objComputers = Get-Content Servers.txt
 foreach ($Computer in $objComputers) 
{ 
$wmi = gwmi win32_service | where {$_.StartMode -ne "Disabled"} | select name,startname
"Name" +$_.name
"StartName" +$_.startname                                                                        
}   
