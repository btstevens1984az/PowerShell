# Purpose: SimplePasswordEncryption — PowerShell automation.
"Password1" | ConvertTo-SecureString -Force -AsPlainText | ConvertFrom-SecureString  > .\password.txt
$password = Get-Content .\password.txt | ConvertTo-SecureString
New-Object -TypeName PSCredential -ArgumentList "Contoso\UserName",$password
