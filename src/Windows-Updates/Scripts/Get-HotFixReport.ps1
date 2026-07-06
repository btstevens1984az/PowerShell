# Purpose: Get-HotFixReport — Windows Update and patch management.
###-------------------------------------------###    
###Email<btstevens1984az@gmail.com>-------###    
###-------------------------------------------###    
###/////////.......................\\\\\\\\\\\###    
###///////////..................\\\\\\\\\\\\\\###
Function Get-HotFixReport { 
$computers = Get-Content C:\Temp\Computers.txt   
$ErrorActionPreference = 'Stop'   
ForEach ($computer in $computers) {  
 
  try  
    { 
Get-HotFix -cn $computer | Select-Object PSComputerName,HotFixID,Description,InstalledBy,InstalledOn | FT -AutoSize 
  
    } 
 
catch  
 
    { 
Write-Warning "System Not reachable:$computer" 
    }  
} 
Hotfixreport > "C:\Temp\HotFixReport.txt"
} 
