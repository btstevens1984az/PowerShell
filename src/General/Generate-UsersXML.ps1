# Purpose: Generate-UsersXML — General-purpose PowerShell utilities.
$users = import-csv C:\PShell\Labs\Lab_9\Contoso-Users.txt -Header "Firstname","Lastname"

$users | 
Select-Object -First 4 |
Foreach-object {
Add-Member -InputObject $_ -MemberType NoteProperty -Name Name -Value "$($_.firstname).$($_.lastname)" 
Add-Member -InputObject $_ -MemberType NoteProperty -Name SamAccountName -Value "$($_.firstname).$($_.lastname)" 
Add-Member -InputObject $_ -MemberType NoteProperty -Name Country -Value "AU" 
Add-Member -InputObject $_ -MemberType NoteProperty -Name Company -Value "Contoso" 
Add-Member -InputObject $_ -MemberType NoteProperty -Name Department -Value $_.FirstName 
Add-Member -InputObject $_ -MemberType NoteProperty -Name City -Value "Sydney" 
Add-Member -InputObject $_ -MemberType NoteProperty -Name Address -Value "1 Platypus Way, Darlinghurst" 
Add-Member -InputObject $_ -MemberType NoteProperty -Name State -Value "NSW" 
Add-Member -InputObject $_ -MemberType NoteProperty -Name Division -Value "Management" 
Add-Member -InputObject $_ -MemberType NoteProperty -Name PostCode -Value 2000 
Add-Member -InputObject $_ -MemberType NoteProperty -Name EmployeeID -Value  ([int]$i+5000)
Add-Member -InputObject $_ -MemberType NoteProperty -Name LogonScript -Value "\\Contoso.com\Netlogon\LogonScript.ps1" 
Add-Member -InputObject $_ -MemberType NoteProperty -Name AccountExpirationDate ( (Get-Date).AddMonths((Get-Random -Minimum 1 -Maximum 60)) )
}

$users | 
Select-Object -Skip 4 |

Foreach-object {
Add-Member -InputObject $_ -MemberType NoteProperty -Name Name -Value "$($_.firstname.substring(0,1)).$($_.lastname)" 
Add-Member -InputObject $_ -MemberType NoteProperty -Name SamAccountName -Value "$($_.firstname.substring(0,1)).$($_.lastname)" 
Add-Member -InputObject $_ -MemberType NoteProperty -Name Country -Value "AU" 
Add-Member -InputObject $_ -MemberType NoteProperty -Name Company -Value "Contoso" 
Add-Member -InputObject $_ -MemberType NoteProperty -Name LogonScript -Value "\\Contoso.com\Netlogon\LogonScript.ps1" 
Add-Member -InputObject $_ -MemberType NoteProperty -Name AccountExpirationDate ( (Get-Date).AddMonths((Get-Random -Minimum 1 -Maximum 60)) )
}

$i=1

$users | Select-Object -Skip 4 | ForEach-Object {

if ($i -le 25) 
{
Add-Member -InputObject $_ -MemberType NoteProperty -Name Department -Value "Finance" 
Add-Member -InputObject $_ -MemberType NoteProperty -Name City -Value "Sydney" 
Add-Member -InputObject $_ -MemberType NoteProperty -Name Address -Value "1 Platypus Way, Darlinghurst" 
Add-Member -InputObject $_ -MemberType NoteProperty -Name State -Value "NSW" 
Add-Member -InputObject $_ -MemberType NoteProperty -Name Division -Value "Gadgets" 
Add-Member -InputObject $_ -MemberType NoteProperty -Name PostCode -Value 2000 
Add-Member -InputObject $_ -MemberType NoteProperty -Name EmployeeID -Value  ([int]$i+1000)
}

if ($i -gt 25 -and $i -le 50) 
{
Add-Member -InputObject $_ -MemberType NoteProperty -Name Department -Value "Marketing"
Add-Member -InputObject $_ -MemberType NoteProperty -Name City -Value "Melbourne"  
Add-Member -InputObject $_ -MemberType NoteProperty -Name Address -Value "23 Koala Way, Frankston" 
Add-Member -InputObject $_ -MemberType NoteProperty -Name State -Value "VIC"
Add-Member -InputObject $_ -MemberType NoteProperty -Name Division -Value "Widgets" 
Add-Member -InputObject $_ -MemberType NoteProperty -Name PostCode -Value 3000
Add-Member -InputObject $_ -MemberType NoteProperty -Name EmployeeID -Value  ([int]$i+2000)
}

if ($i -gt 50 -and $i -le 75) 
{
Add-Member -InputObject $_ -MemberType NoteProperty -Name Department -Value "Engineering" 
Add-Member -InputObject $_ -MemberType NoteProperty -Name City -Value "Brisbane" 
Add-Member -InputObject $_ -MemberType NoteProperty -Name Address -Value "34 Kangaroo Way, Spring Valley" 
Add-Member -InputObject $_ -MemberType NoteProperty -Name State -Value "QLD"
Add-Member -InputObject $_ -MemberType NoteProperty -Name Division -Value "Gadgets" 
Add-Member -InputObject $_ -MemberType NoteProperty -Name PostCode -Value 4000
Add-Member -InputObject $_ -MemberType NoteProperty -Name EmployeeID -Value  ([int]$i+3000)
}

if ($i -gt 75 -and $i -le 100) 
{
Add-Member -InputObject $_ -MemberType NoteProperty -Name Department -Value "IT"
Add-Member -InputObject $_ -MemberType NoteProperty -Name City -Value "Perth" 
Add-Member -InputObject $_ -MemberType NoteProperty -Name Address -Value "72 Kookaburra Way, North Bridge" 
Add-Member -InputObject $_ -MemberType NoteProperty -Name State -Value "WA"  
Add-Member -InputObject $_ -MemberType NoteProperty -Name PostCode -Value 5000
Add-Member -InputObject $_ -MemberType NoteProperty -Name Division -Value "Widgets"
Add-Member -InputObject $_ -MemberType NoteProperty -Name EmployeeID -Value  ([int]$i+4000)
}

$i++

}

$users | Export-Clixml -Path C:\PShell\Labs\Lab_9\Contoso-UserImport.xml


