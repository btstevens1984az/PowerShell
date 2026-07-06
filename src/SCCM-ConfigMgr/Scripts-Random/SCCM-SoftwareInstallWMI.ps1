# Purpose: SCCM-SoftwareInstallWMI — Configuration Manager collections and deployments.
#   James Wylde

$cred = Get-Credential

CLS

$computer = Get-Content -Path c:\temp\sapcomputers.txt


Invoke-Command -ComputerName $computer -ScriptBlock {
   
$i = Get-WmiObject -Class CCM_Program -Namespace "root\ccm\clientsdk" | Where-Object { $_.Name -like "SAP Logon For Windows_x86_7.60_ML" }    
Invoke-WmiMethod -class CCM_ProgramsManager -Namespace "root\ccm\clientsdk" -Name ExecutePrograms -argumentlist $i -Credential $cred

    
}