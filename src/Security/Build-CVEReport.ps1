# Purpose: Build-CVEReport — Security auditing and compliance checks.
Function Build-CVEReport {### Install the module from the PowerShell Gallery (must be run as Admin)
Install-Module -Name msrcsecurityupdates -force
Import-module msrcsecurityupdates
Set-MSRCApiKey -ApiKey "1bd79db501ce49a5ae1a117a2de252c8" -Verbose

Get-MsrcCvrfDocument -ID '2017-Apr' | Get-MsrcSecurityBulletinHtml -Verbose | Out-File c:\WULogs\MSRCAprilSecurityUpdates.html
}