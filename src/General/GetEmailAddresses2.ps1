# Purpose: GetEmailAddresses2 — General-purpose PowerShell utilities.
#$emails = Get-Content C:\cust\emails.txt
#demo https://en.wikipedia.org/wiki/Email_address#Valid_email_addresses
$emails = Get-Clipboard
$regex ="\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b"
$EmailAddresses = $emails  | select-string -Pattern $regex -AllMatches |
    ForEach-Object{$_.matches.value} | select-object -Unique
#$EmailAddresses > c:\temp\fixemails.txt
$EmailAddresses -join ";" | Out-Clipboard