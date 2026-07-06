# Purpose: AD-LockedOut — Active Directory user, group, and domain administration.
Search-ADAccount -SearchBase "OU=GBR,OU=SK,DC=group,DC=wan" –LockedOut | Select -Property Name,DistinguishedName

$DC = Get-ADComputer -Filter * -SearchBase "OU=Domain Controllers,DC=domain,DC=com" | Select DNSHostname
$properties = @(
    @{n='User';e={$_.Properties[0].Value}},
    @{n='Locked by';e={$_.Properties[1].Value}},
    @{n='TimeStamp';e={$_.TimeCreated}}
)
Foreach ($D in $DC)
{
Get-WinEvent -ComputerName $D.DNSHostname -FilterHashTable @{LogName='Security'; ID=4740} | Select $properties} | Export-csv C:\Users\$env:username\Desktop\LockedUsers.csv -NoTypeInformation -Encoding Unicode