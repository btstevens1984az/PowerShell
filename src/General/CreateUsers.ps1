# Purpose: CreateUsers — General-purpose PowerShell utilities.
"Engineering","Finance","Marketing","IT" | 
New-ADOrganizationalUnit -Path "OU=Personnel,DC=Contoso,DC=com" �Name {$_}

$password = ConvertTo-SecureString -String 'PowerShell4' -AsPlainText -Force

Import-CliXml -Path C:\PShell\Labs\Lab_9\Contoso-UserImport.xml |
New-ADUser -Path {"OU=$($_.Department),OU=Personnel,DC=Contoso,DC=com"} `
-GivenName {$_.Firstname} -Surname {$_.Lastname} `
-ScriptPath {$_.LogonScript} -StreetAddress {$_.Address} `
-PostalCode {$_.PostCode} -EmployeeNumber {$_.EmployeeID} `
-DisplayName {"$($_.FirstName) $($_.LastName)"} `
-AccountPassword $password -Enabled $true -PassThru