# Purpose: Create-Contacts — General-purpose PowerShell utilities.
$text = Import-Csv C:\contacts.csv
foreach($line in $text)
{
	#Write-Host $line.FullName $line.FirstName $line.LastName $line.EMAIL $line.Phone $line.Title $line.Dept
	$exists = Get-QADObject -Name $line.FullName
	if($exists -eq $null)
	{
		#Write-Host $line.FullName $line.FirstName $line.LastName $line.EMAIL $line.Phone $line.Title $line.Dept
		New-QADObject -ParentContainer 'OU=Contacts,DC=lab,DC=local' -type 'Contact' -NamingProperty 'CN' -Name $line.FullName -ObjectAttributes @{displayName=$line.FullName;givenName=$line.FirstName;sn=$line.LastName;mail=$line.EMAIL;telephonenumber=$line.Phone;title=$line.Title;department=$line.Dept}
	}
	elseif($exists -ne $null)
	{
		Write-Host $exists 'exists'
	}
}