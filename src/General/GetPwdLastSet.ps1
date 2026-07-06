# Purpose: GetPwdLastSet — General-purpose PowerShell utilities.
# powershell2
# kerry kreitinger
# show last logon - password set - password expires

$strPathLastLogons= "H:\AD-Reports\Lastlogons9-9-2010-2PM.csv"

$dom = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
$root = $dom.GetDirectoryEntry()
$search = [System.DirectoryServices.DirectorySearcher]$root
$search.Filter = "(objectClass=User)"

Get-QADUser -IncludeAllProperties -sizelimit 0 | Select-Object CN, SamAccountName, passwordexpires, pwdLastSet, LastLogon, email, passwordstatus, passwordneverexpires, phoneNumber | Export-Csv -Path $strPathLastLogons

