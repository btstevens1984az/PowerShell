# Purpose: Set-PasswordEncryption — PowerShell automation.
Function Set-PasswordEncryption {
"Type Your password in here" | ConvertTo-SecureString -Force -AsPlainText | ConvertFrom-SecureString > C:\Temp\Password.txt
$Password = Get-Content C:\Temp\Password.txt | ConvertTo-SecureString
New-Object -TypeName PSCredential -ArgumentList "$env:USERDOMAIN\$env:USERNAME",$password
}
