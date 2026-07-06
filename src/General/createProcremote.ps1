# Purpose: createProcremote — General-purpose PowerShell utilities.
#JD
#demo using WMICLASS type accelerator

#set for localhost
$computer = "."

#create process and return pid to $procID variable
Write-Host "Creating Process"
$objprocID =([WMICLASS]"\\$computer\root\CIMv2:win32_process").Create("notepad.exe")
$procid = $objprocid.processid
#sleep for a bit
Start-Sleep 1

#get process object to terminate it
Write-Host "terminating process"
Get-WmiObject win32_process -filter "processid = $procid"  | %{$_.terminate()} | Out-Null

