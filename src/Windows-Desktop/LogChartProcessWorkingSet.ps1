# Purpose: LogChartProcessWorkingSet — Windows desktop configuration and management.
﻿
# -----------------------------------------------------------------------------
# LogChartProcessWorkingSet.ps1
# ed wilson, msft
# 8/14/2009
# Windows PowerShell Best Practices
# -----------------------------------------------------------------------------
Param([switch]$trace)
$trace=$true
$errorActionPreference = "SilentlyContinue"
$error.Clear()
$startTime = $endTime = $null


$logDir = "c:\fso"
if(-not(Test-Path -path $logdir)) 
  { New-Item -Path $logdir -ItemType directory | out-null }
$traceLog = Join-Path -Path $logDir -ChildPath "Tracelog.txt"
$startTime = (Get-Date).tostring()

If($trace) 
  {"**Starting script: $($MyInvocation.InvocationName) $startTime" >> $traceLog} 
If($trace) 
  {"Creating msgraph.application object" >> $traceLog} 
$chart = New-Object -ComObject msgraph.application
$chart.visible = $true
If($trace) 
  {"Adding chart column labels" >> $traceLog} 
$chart.datasheet.cells.item(1,1) = "Process Name"
$chart.datasheet.cells.item(1,2) = "Working Set"
If($trace) 
  {"Adding Data to chart" >> $traceLog}
$r = 2
If($trace) 
  {"Obtaining process information" >> $traceLog} 
  
Get-Process | 
ForEach-Object {
  $chart.datasheet.cells.item($r,1) = $_.name
  $chart.datasheet.cells.item($r,2) = $_.workingSet
  $r++
} # end foreach process

$endTime = (Get-Date).tostring()
If($trace) 
  {"**ending script $endTime. " >> $traceLog}
If($trace) 
  {"**Total script time was $((New-TimeSpan -Start $startTime `
  -End $endTime).totalSeconds) seconds`r`n" >> $traceLog}
 "*** LISTING $($error.count) Errors ***" >> $traceLog
 Foreach ($e in $error) { $e >> $tracelog }