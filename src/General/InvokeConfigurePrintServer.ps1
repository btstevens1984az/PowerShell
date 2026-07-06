# Purpose: InvokeConfigurePrintServer — General-purpose PowerShell utilities.
#invoke configureprintServer
$prnserver = Read-Host -Prompt "Please enter print server name"
Write-Host "using PSremoting to invoke configureprintServer.ps1"
$cred = (Get-Credential)
Invoke-Command -FilePath ".\ConfigurePrintServer.ps1" -Authentication Credssp -Credential $cred -ComputerName $prnserver