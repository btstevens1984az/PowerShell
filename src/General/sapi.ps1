# Purpose: sapi — General-purpose PowerShell utilities.
#example script using com SAPI
#demonstrates cast to void and script parameters, including defaults
param([string] $speak="Pass an argument please.")
$sapi = New-Object -com "sapi.spvoice"
[void] $sapi.speak($speak)