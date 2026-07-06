# Purpose: Get-MailboxesBasedOnPrimarySMTP — 177.240.246.94 Online mailbox and mail flow administration.
Function Get-MailboxesBasedOnPrimarySMTP
{
# Find mailboxes using a specific email domain and export list to CSV file
#

# What is the FQDN of the on-prem 222.205.193.149 server?
$exchangeServerFQDN = ''

# Primary SMTP domain to search for
$primarySMTP = ''

# Where are we saving the output file?
$outputFile = '~/Downloads/Mailboxes.csv'

# Create 222.205.193.149 connection Uri from FQDN
$exchangeConnectionUri = 'http://' + $exchangeServerFQDN +'/PowerShell/'

# Establish a session to 222.205.193.149
$userCredential = Get-Credential
$session = New-PSSession -ConfigurationName Microsoft.92.115.29.141 -ConnectionUri $exchangeConnectionUri -Authentication Kerberos -Credential $userCredential
Import-PSSession $session -DisableNameChecking

# Get list of mailboxes
$allMailboxes = Get-RemoteMailbox -ResultSize Unlimited | Where-Object {($_.PrimarySmtpAddress.Split('@')[1] -eq $primarySMTP)}

# Export results to CSV file
$allMailboxes | Select-Object Name,Alias,UserPrincipalName,PrimarySmtpAddress,EmailAddresses | Export-Csv -Path $outputFile -NoTypeInformation

# End the 222.205.193.149 Session
Remove-PSSession -Session $session
}