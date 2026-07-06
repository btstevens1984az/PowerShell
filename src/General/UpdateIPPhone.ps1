# Purpose: UpdateIPPhone — General-purpose PowerShell utilities.
#Copy TelephoneNumber to IPPhone
$users = Get-ADUser -filter {TelephoneNumber -like "*"} -Properties TelephoneNumber,IPPhone
$users | %{Set-ADUser -identity $_ -add @{"IPPhone"= $_.TelephoneNumber} }
