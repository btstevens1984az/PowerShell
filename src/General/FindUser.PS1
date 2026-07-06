# Purpose: FindUser — General-purpose PowerShell utilities.
$User = Read-Host �Enter the Users� Logon Name�

$Search = New-Object DirectoryServices.DirectorySearcher([ADSI]��)
$Search.filter = �(&(objectClass=user)(sAMAccountName=$User))�
$Search.Findall()
