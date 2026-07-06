# Purpose: Get-ProcUtilization — General-purpose PowerShell utilities.
# this very slow... async or parallel jobs would be needed to do large numbers



$LogOutputTrans = $((Get-Date).ToString('yyyyMMdd-hhmm') + "_ProcUtilization.txt")
start-transcript -Path "\\114.148.18.125\updatesinventory$\Transcripts\$LogOutputTrans" -IncludeInvocationHeader

$proclist= (Get-Process -includeUserName| Sort CPU -descending | Select -first 10 -Property ID,ProcessName,CPU)

Foreach ($p in $proclist) {
$p | Add-Member -type NoteProperty -name UserID -value ((Get-WmiObject -class win32_process | where{$_.ProcessID -eq $p.id}).getowner()).user
$p | Add-Member -type NoteProperty -name PercentCPU -value (get-wmiobject Win32_PerfFormattedData_PerfProc_Process | where{$_.IDProcess -eq $p.id}).PercentProcessorTime
	}
	
$proclist | Format-Table Id, ProcessName, CPU, PercentCPU, UserID

$HighestProc= (Get-Process | Sort CPU -descending | Select -first 1 -Property ID,ProcessName,CPU)


write-host Process utilizing highest CPU $highestProc.ProcessName
stop-transcript
