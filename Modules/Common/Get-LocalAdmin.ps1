# Purpose: Get-LocalAdmin — Reusable PowerShell function libraries.
Function Get-LocalAdmin {  
param ($ComputerName)  
  
$admins = Gwmi win32_groupuser –computer $ComputerName   
$admins = $admins |? {$_.groupcomponent –like '*"Administrators"'}  
  
$admins |% {  
$_.partcomponent –match “.+Domain\=(.+)\,Name\=(.+)$” > $nul  
$matches[1].trim('"') + “\” + $matches[2].trim('"')  
}  
}