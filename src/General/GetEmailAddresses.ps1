# Purpose: GetEmailAddresses — General-purpose PowerShell utilities.
$emails = Get-Content C:\cust\emails.txt
$regex ="\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b"
$results = $emails -split ";"| % {$_ | Select-String -Pattern $regex}
$EmailAddresses = $results | %{$_.matches} | %{$_.value} | select-object -Unique
$EmailAddresses > c:\cust\fixemails.txt