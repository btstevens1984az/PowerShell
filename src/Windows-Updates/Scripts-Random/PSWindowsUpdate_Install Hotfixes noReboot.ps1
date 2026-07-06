# Purpose: PSWindowsUpdate Install Hotfixes noReboot — Windows Update and patch management.
Import-Module "C:\Windows\System32\WindowsPowerShell\v1.0\Modules\PSWindowsUpdate"
$Script = {ipmo PSWindowsUpdate; Get-WUInstall -AcceptAll -IgnoreReboot | Out-File 'C:\Users\$env:USERNAME\Desktop\BStevensPowerShellGUI\Deploy-master\DEPLOY\Logs\PSWindowsUpdate.log'}
Invoke-WUInstall -ComputerName $computername -script $script -confirm:$false