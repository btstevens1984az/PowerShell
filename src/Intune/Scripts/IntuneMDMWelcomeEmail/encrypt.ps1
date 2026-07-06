# Purpose: encrypt — Microsoft Intune endpoint management.
$password = read-host -prompt "Enter your Password"
write-host "$password is password"
$secure = ConvertTo-SecureString $password -force -asPlainText
$bytes = ConvertFrom-SecureString $secure
$bytes | out-file .\password1.txt
