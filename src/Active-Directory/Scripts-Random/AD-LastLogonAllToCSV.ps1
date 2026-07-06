# Purpose: AD-LastLogonAllToCSV — Active Directory user, group, and domain administration.
#   James Wylde 2020

#----------------------------------------------------------------------------------------#
#   Modules
Import-Module ActiveDirectory

# If Excel is not present, change file extension to either .XML or .TXT
$FileOut = 'C:\Temp\Exports\Logons5Days.csv'

Out-File $FileOut -Encoding utf8 -Force

$TableHeader = 'Account Name, Name, Email Address, Last Logon Date, Last Logon Time'
Write-Output $TableHeader | Out-File $FileOut -Encoding utf8 -Append

$Users = Get-ADUser -Filter '(enabled -eq $True)' -Properties lastLogon,mail

foreach ($User in $Users) {
    $LastLogonDate = [datetime]::FromFileTime($User.lastLogon).ToString('dd/MM/yyyy')
    $LastLogonTime = [datetime]::FromFileTime($User.lastLogon).ToString('HH:MM:SS')

    $Output = $User.SamAccountName + ',' + $User.Name + ',' + $User.Mail + ',' + $LastLogonDate + ',' + $LastLogonTime

    Write-Output $Output | Out-File $FileOut -Encoding utf8 -Append
}
