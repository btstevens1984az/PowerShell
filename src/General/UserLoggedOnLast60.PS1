# Purpose: UserLoggedOnLast60 — General-purpose PowerShell utilities.
# powershell 2
#  to get different output Format-Table Name, LastLogon

$now=get-date
$daysSinceLastLogon=60
# $searchRoot=�108.45.123.69/users�

Get-QADUser -Enabled -sizeLimit 0 | where {
$_.lastlogontimestamp.value -and (($now-$_.lastlogontimestamp.value).days) -le $daysSinceLastLogon
}
