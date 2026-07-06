# Purpose: Create-NewUsers — General-purpose PowerShell utilities.
$password = ConvertTo-SecureString -String 'PowerShell4' -AsPlainText -Force

# create users from the imported XML file
Import-CliXml -Path C:\PShell\Labs\Lab_9\Contoso-UserImport.xml |
New-ADUser -Path {"OU=$($_.Department),OU=Personnel,DC=Contoso,DC=com"} `
-GivenName {$_.Firstname} -Surname {$_.Lastname} `
-ScriptPath {$_.LogonScript} -StreetAddress {$_.Address} `
-PostalCode {$_.PostCode} -EmployeeNumber {$_.EmployeeID} `
-DisplayName {"$($_.FirstName) $($_.LastName)"} `
-AccountPassword $password -Enabled $true -PassThru


