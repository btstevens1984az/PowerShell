# Purpose: Build-CVEReport — Windows Update and patch management.
Function Build-CVEReport {### Install the module from the PowerShell Gallery (must be run as Admin)
Install-Module -Name msrcsecurityupdates -force
Import-module msrcsecurityupdates
Set-MSRCApiKey -ApiKey "1bd79db501ce49a5ae1a117a2de252c8" -Verbose

Get-MsrcCvrfDocument -ID '2018-Jun' | Get-MsrcSecurityBulletinHtml -Verbose | Out-File C:\Temp\MSRCAprilSecurityUpdates.html
}
