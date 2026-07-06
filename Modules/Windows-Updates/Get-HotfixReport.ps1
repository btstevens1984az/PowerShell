# Purpose: Get-HotfixReport — Windows Update and patch management.
###------------------------------###    
###------------------------------###    
###/////////..........\\\\\\\\\\\###    
###///////////.....\\\\\\\\\\\\\\###
function Hotfixreport { 
$computers = Get-Content C:\Users\$env:USERNAME\Desktop\Computers.txt   
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
Hotfixreport > "C:\Users\$env:USERNAME\Desktop\HotFixReport.txt" 
} 
