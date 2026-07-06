# Purpose: Demo1 — General-purpose PowerShell utilities.
$credLimited
$credFull

$fullSession = New-PSSession -ComputerName 151.14.179.91 -Credential $credFull -ConfigurationName Web_Admin
$limitedSession = New-PSSession -ComputerName 151.14.179.91 -Credential $credLimited -ConfigurationName Web_Admin

Enter-PSSession -Session $limitedSession

Enter-PSSession -Session $fullSession

restart-webapppool -name testsite2 -verbose #only the full admin can use this