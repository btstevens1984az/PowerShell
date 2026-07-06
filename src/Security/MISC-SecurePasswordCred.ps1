# Purpose: MISC-SecurePasswordCred — Security auditing and compliance checks.


Read-Host -AsSecureString | ConvertFrom-SecureString | out-file c:\temp\ss.txt
$username = "dom\user"
$pass = Get-content "C:\temp\ss.txt" | ConvertTo-SecureString
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username,$pass

-Credential $cred