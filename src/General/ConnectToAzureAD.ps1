# Purpose: ConnectToAzureAD — General-purpose PowerShell utilities.
#https://msdn.microsoft.com/en-us/library/azure/jj151815.aspx#bkmk_installmodule
$msolcred = get-credential
connect-msolservice -credential $msolcred

Get-MsolUser
#Set-MsolUser -PasswordNeverExpires $true