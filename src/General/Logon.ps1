# Purpose: Logon — General-purpose PowerShell utilities.
# -----------------------------------------------------------------------------
# Logon.ps1
# ed wilson, msft
# LASTEDIT: 8/8/2009
# VERSION: 1.0.0
#
#
# -----------------------------------------------------------------------------
$ErrorActionPreference = "SilentlyContinue"
if(-not(Test-path -path HKCU:\Software\logonScripts))
 {
  new-Item -path HKCU:\Software\logonScripts
  new-Itemproperty -path HKCU:\Software\logonScripts -name logon `
   -Value $(get-date).tostring() -Force
  new-Itemproperty -path HKCU:\Software\logonScripts -name user `
   -Value $env:USERNAME -Force
 }
else
 {
  set-Itemproperty -path HKCU:\Software\logonScripts -name logon `
   -Value $(get-date).tostring() -Force
  set-Itemproperty -path HKCU:\Software\logonScripts -name user `
   -Value $env:USERNAME -Force
 }

try
{
 New-EventLog -source logonscript -logname logonscript
}
Catch{ [System.Exception] }
Finally
{ 
 Write-EventLog -LogName logonscript -Source logonScript `
  -EntryType information `
 -EventId 1 `
 -Message "logon script $($myinvocation.invocationName) ran at $(get-date)"
}
$ErrorActionPreference = "Continue"