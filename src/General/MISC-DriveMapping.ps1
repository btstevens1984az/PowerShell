# Purpose: MISC-DriveMapping — General-purpose PowerShell utilities.
#   James Wylde 2020

#----------------------------------------------------------------------------------------#
#   Modules

Invoke-Command -ComputerName 168.23.139.1 -Scriptblock { New-SmbMapping -LocalPath 'S:' -RemotePath '\\19.131.54.185\S' -UserName Get-Credential.UserName -Password Get-Credential.GetNetworkCredential.Password }