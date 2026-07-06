# Purpose: Save-CredToFile — Microsoft 365 tenant administration.
Function Save-CredToFile
{
$systemmessagecolor = "cyan"
$processmessagecolor = "green"
$credpath = "/Users/btstevens1984/Documents/Creds.xml"
Clear-Host
write-host -foregroundcolor $systemmessagecolor "Script started`n"
Get-Credential | Export-CliXml  -Path $credpath
write-host -foregroundcolor $systemmessagecolor "Script completed`n"
]