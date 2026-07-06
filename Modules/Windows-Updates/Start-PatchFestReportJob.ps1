# Purpose: Start-PatchFestReportJob — Windows Update and patch management.
Function Start-PatchFestReportJob {
  $Servers = @('125.98.166.125')
  Add-TrustedHost -Computer $Servers
  $cred = Get-Credential
  Start-PatchFestReport -Computers $Servers -Credential $cred -ReportFormat Excel -ReportType Troubleshooting -Verbose
  Remove-TrustedHost -Computer $Servers
}