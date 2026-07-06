# Purpose: Local Account Management — General-purpose PowerShell utilities.
#  Local Account Management

Get-LocalUser

$date = (Get-Date).addmonths(6)
$pass = ConvertTo-SecureString -String 'qw12QW!@' -AsPlainText -Force
New-LocalUser -Name btsteVM -AccountExpires $date -Password $pass  -Description Consultant
Get-LocalUser -Name btsteV< | Format-Table name, *Source,*exp*

New-LocalGroup -Name WIN10PROGroup -Description 'Members of  WIN10PROGroup'
Add-LocalGroupMember -Group WIN10PROGroup -Member btste
Get-LocalGroupMember -Group WIN10PROGroup