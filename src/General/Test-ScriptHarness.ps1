# Purpose: Test-ScriptHarness — General-purpose PowerShell utilities.
﻿# -----------------------------------------------------------------------------
# Test-ScriptHarness.ps1
# ed wilson, msft
# 7/9/2009
# runs all ps1 scripts in a specified folder and looks
# for errors. Logs the number of errors, as well as the
# total elasped time for the script to run. 
# *** Caution ... this can have potetially devistating 
# effects on your computer ... make sure YOU KNOW WHAT
# the scripts in the folder will do to your computer ***
# 
# -----------------------------------------------------------------------------
if((Get-WmiObject win32_computersystem).model -ne "virtual machine")
  {
    $response = Read-Host -prompt "This script is best run in a VM. 
    Do you wish to continue? <y / n>"
    if ($response -eq "n") { exit }
  }
$path = "C:\bp"
$report = [io.path]::GetTempFileName()
Get-ChildItem -Path $path -Include *.ps1 -Recurse |
ForEach-Object -Begin `
  { 
   $stime = Get-Date
   $ErrorActionPreference = "SilentlyContinue" 
   "Testing ps1 scripts in $path $stime" | 
     Out-File -append -FilePath $report
  } -Process `
  {
   $error.Clear() 
   $startTime = Get-Date
   "  Begin Testing $_ at $startTime" | 
     Out-File -append -FilePath $report
   Invoke-Expression -Command $_ 
   $endTime = Get-Date
   "  End testing $_ at $endTime." | 
     Out-File -append -FilePath $report
   "    Script generated $($error.Count) errors" | 
     Out-File -append -FilePath $report
   "    Elasped time: $($endTime - $startTime)" |
     Out-File -append -FilePath $report
  } -end `
  { 
   $etime = Get-Date
   $ErrorActionPreference = "Continue"
   "Completed testing all scripts in $path $etime" | 
     Out-File -append -FilePath $report
   "Testing took $($etime - $stime)" | 
     Out-File -append -FilePath $report
  }
  
  Notepad $report