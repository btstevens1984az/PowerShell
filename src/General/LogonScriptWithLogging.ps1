# Purpose: LogonScriptWithLogging — General-purpose PowerShell utilities.
﻿# ----------------------------------------------------------------------
# LogonScriptWithLogging.ps1
# ed wilson, msft, 8/15/2009
# PowerShell Best Practices
# ----------------------------------------------------------------------
$errorActionPreference = "SilentlyContinue"
$error.Clear()
$startTime = $endTime = $Message = $logResults = $null

$logDir = "c:\fso"
if(-not(Test-Path -path $logdir)) 
  { New-Item -Path $logdir -ItemType directory | out-null }
$logonLog = Join-Path -Path $logDir -ChildPath "logonlog.txt"

$startTime = (Get-Date).tostring()
$wshNetwork = New-Object -ComObject wscript.network
$wshNetwork.MapNetworkDrive("f:","\\157.217.58.110\studentShare")
$message += "`r`nMapping drive f to \\157.217.58.110\student share `r`n$($error[0])"
$wshNetwork.SetDefaultPrinter("berlinPrinter")
$message += "`r`nSetting default printer to berlinPrinter `r`n$($error[0])"

$endTime = (Get-Date).tostring()
$logResults = @"
**Starting script: $($MyInvocation.InvocationName) $startTime.
 $message
**Ending logon script $endTime. 
**Total script time was $((New-TimeSpan -Start $startTime `
  -End $endTime).totalSeconds) seconds.
"@
$logResults > $logonLog