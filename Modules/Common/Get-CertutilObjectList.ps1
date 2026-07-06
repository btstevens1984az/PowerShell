# Purpose: Get-CertutilObjectList — Reusable PowerShell function libraries.
Function Get-CertutilObjectList {
param( 
 [Alias("CN","Computer")] 
 [String[]]$ComputerName="$env:COMPUTERNAME"
 ) 

$certutil = "$($env:SystemRoot)\system32\certutil.exe" 
$certutilObjectList = Get-CertutilObjectList (Invoke-Expression "$certutil") 
$certutilObjectList = Get-CertutilObjectList (Invoke-Expression "$certutil -view -restrict 'Certificate Template=<my.template.oid>'") 
$certutilObjectList = Get-CertutilObjectList (Invoke-Expression "$certutil -view -restrict 'disposition=20,notbefore>01/01/2018'")
}