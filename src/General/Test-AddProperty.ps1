# Purpose: Test-AddProperty — General-purpose PowerShell utilities.

$HighestProc= (Get-Process | Sort CPU -descending | Select -first 1 -Property ID,ProcessName,CPU)

(get-wmiobject Win32_PerfFormattedData_PerfProc_Process | where{$_.IDProcess -eq $HighestProc.id}).PercentProcessorTime

write-host -Foregroundcolor yellow $HighestProc