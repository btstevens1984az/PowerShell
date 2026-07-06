# Purpose: ConfigItem-Win10 Discovery ShowRunAsDifferentuserinStart — Windows desktop configuration and management.
$regkey = 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer'
$name = 'ShowRunAsDifferentuserinStart'
$Compliance = 'Compliant'
$Check = Get-ItemProperty -Path "$regkey" -Name "$name" -ErrorAction SilentlyContinue
If ($Check) {$Compliance = 'Non-Compliant'}
$Compliance