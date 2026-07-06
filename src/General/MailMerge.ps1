# Purpose: MailMerge — General-purpose PowerShell utilities.
$user = Get-ADUser J.Smith -Properties *

$mailMerge = @"
$($user.givenName) $($user.Surname)

$($user.StreetAddress)
$($user.l)
$($user.State)
$($user.PostalCode)
$($user.Country)


Dear $($user.GivenName),

Your Microsoft Active Directory account has been created with the following information.
Please review and notify us in the event of incorrect personal details.

Logon Name: $($user.samaccountname)
Division: $($user.Division)
Department: $($user.Department)
Company: $($user.Company)

Kind Regards,

Alan M. Turning
"@

$mailMerge | Out-Printer -Name "Microsoft XPS Document Writer"