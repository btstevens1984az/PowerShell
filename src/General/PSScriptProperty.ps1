# Purpose: PSScriptProperty — General-purpose PowerShell utilities.

$file = Get-ChildItem -Path . -Filter *.txt

$file | Add-Member -MemberType ScriptProperty -Name CurrentTime -value {Get-Date -DisplayHint time}

$file.currentTime
 