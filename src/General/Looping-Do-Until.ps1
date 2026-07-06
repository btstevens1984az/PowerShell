# Purpose: Looping-Do Until — General-purpose PowerShell utilities.
# Looping-Do-Until.ps1
#
 
$MinimumLength=(Get-ADdefaultDomainPasswordPolicy).MinPasswordLength

Do 
{
   write-host "Password must be at least $MinimumLength characters long"
   $pwd = Read-Host "Enter a Password" -AsSecureString
} 

Until ($pwd.Length -GE $MinimumLength)

Write-Host "Password Accepted"
