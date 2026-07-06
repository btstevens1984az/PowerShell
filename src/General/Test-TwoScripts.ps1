# Purpose: Test-TwoScripts — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE: 7/11/2009
#
# KEYWORDS: Measure-Command, Return, Function
# Percent change
# COMMENTS: This script runs the Measure-Command on
# two similiar scripts to see if changes to the scripts improves
# their performance. You can select number of tests to run
# as well as whether to log the results of the testing to the
# scripts.
#
# ------------------------------------------------------------------------
Param(
  [string]$baseLineScript,
  [string]$modifiedScript,
  [int]$numberOfTests = 20,
  [switch]$log
) #end param

Function Test-Scripts
{
  Param(
  [string]$baseLineScript,
  [string]$modifiedScript
) #end param
 Measure-Command -Expression { $baseLineScript }
 Measure-Command -Expression { $modifiedScript }
} #end Test-Scripts function

Function Get-Change($baseLine, $modified)
{
  (($baseLine - $modified)/$baseLine)*100
} #end Get-Change function

Function Get-TempFile
{
 [io.path]::GetTempFileName()
} #end Get-TempFile function

# *** Entry Point To Script
if($log) { $logFile = Get-TempFile }
For($i = 0 ; $i -le $numberOfTests ; $i++)
{
 "Test $i of $numberOfTests" ; start-sleep -m 50 ; cls
 $results= Test-Scripts -baseLineScript $baseLineScript -modifiedScript $modifedScript
 $baseLine += $results[0].TotalSeconds
 $modified += $results[1].TotalSeconds
 If($log)
  {
     "$baseLineScript run $i of $numberOfTests $(get-date)" >> $logFile
     $results[0] >> $logFile
     "$modifiedScript run $i of $numberOfTests $(get-date)" >> $logFile
     $results[1] >> $logFile
  } #if $log
} #for $i 

"Average change over $numberOfTests tests"
"BaseLine: $baseLineScript average Total Seconds: $($baseLine/$numberOfTests)"
"Modified: $modifiedScript average Total Seconds: $($modified/$numberOfTests)"
"Percent Change: " + "{0:N2}" -f (Get-Change -baseLine $baseLine -modified $modified)
if($log)
{
 "Average change over $numberOfTests tests" >> $logFile
 "BaseLine: $baseLineScript average Total Seconds: $($baseLine/$numberOfTests)" >> $logFile
 "Modified: $modifiedScript average Total Seconds: $($modified/$numberOfTests)" >> $logFile
 "Percent Change: " + "{0:N2}" -f (Get-Change -baseLine $baseLine -modified $modified) >> $logFile
} #if $log
if($log) { Notepad $logFile }
