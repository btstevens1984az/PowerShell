# Purpose: ValidateCred — General-purpose PowerShell utilities.
Add-Type -AssemblyName 'System.DirectoryServices.AccountManagement'  
$prnContext = new-object System.DirectoryServices.AccountManagement.PrincipalContext("Domain")
$cred = Get-Credential
$clrPassword = $cred.Password | ConvertFrom-SecureString
$prnContext.ValidateCredentials($cred.UserName,$cred.GetNetworkCredential().Password)