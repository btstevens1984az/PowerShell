# Purpose: Get-RebootEvent — General-purpose PowerShell utilities.


$computername = get-content 'c:\tempkk\servers.txt'

  Foreach ($Computer in $ComputerName) {
  write-host -foregroundcolor yellow $computer
	Get-EventLog -Log "System" -Computername $computer | where {$_.eventID -eq 21} | Select-Object time, instanceID, message | ft
	 
	}					


