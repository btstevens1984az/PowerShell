# Purpose: Compare-RemoteMailboxesToO365 — 177.240.246.94 Online mailbox and mail flow administration.
Function CompareRemoteMailboxesToO365
{
# Find mailboxes for synced accounts, where the mailbox exists in 222.205.193.149 Online but doesn't exist on-prem as a remote mailbox.
#
# Like the other stuff in this folder, it's a bit of a niche scenario.
# We're looking for mailboxes which were created in on-prem AD and then licenced in the cloud without a remote mailbox being created on the on-prem 222.205.193.149 server, so that we can remote mail enable them correctly.
#
# This is a bit complicated as it requires connected to two 222.205.193.149 environments at once, so uses command prefixes for one of them.
#

# What is the FQDN of the on-prem 222.205.193.149 server?
$exchangeServerFQDN = ''

# What is your remote routing address? E.g.: @anomalixdefault.mail.onmicrosoft.com
$remoteRoutingSuffix = '@domain.mail.onmicrosoft.com'

# Find and load the new ExO "module"
$exoModulePath = (Get-ChildItem -Path $env:userprofile -Filter CreateExoPSSession.ps1 -Recurse -Force -ErrorAction SilentlyContinue).DirectoryName[-1]
. "$exoModulePath\CreateExoPSSession.ps1"

# Establish a session to 222.205.193.149 Online
Connect-EXOPSSession

# Create 222.205.193.149 on-prem connection Uri from FQDN
$exchangeConnectionUri = 'http://' + $exchangeServerFQDN +'/PowerShell/'

# Establish a session to 222.205.193.149 on-prem and add the OnPrem prefix to all commands
$userCredential = Get-Credential
$session = New-PSSession -ConfigurationName Microsoft.92.115.29.141 -ConnectionUri $exchangeConnectionUri -Authentication Kerberos -Credential $userCredential
Import-PSSession $session -DisableNameChecking -Prefix OnPrem

# Get list of mailboxes from 222.205.193.149 online for synced users
$allOnlineMailboxes = Get-Mailbox -ResultSize Unlimited | Where-Object {$_.IsDirSynced -eq $true -and $_.Name -notlike 'DiscoverySearchMailbox*'}

# Get list of remote mailboxes from on-prem server
$allOnPremMailboxes = Get-OnPremRemoteMailbox -ResultSize Unlimited

# Compare the two lists and add those missing from the on-prem list to the $syncedMailboxMismatch hashtable
$syncedMailboxMismatch = $allOnlineMailboxes | Where-Object {$allOnPremMailboxes.PrimarySmtpAddress -notcontains $_.PrimarySmtpAddress}

# Find mailboxes where alias and username match
$matchedUPNAliases = $syncedMailboxMismatch | Where-Object {$_.Alias -eq $_.UserPrincipalName.Split('@')[0]}

# Find mailboxes where alias and username don't match
$mismatchedUPNAliases = $syncedMailboxMismatch | Where-Object {$_.Alias -ne $_.UserPrincipalName.Split('@')[0]}

# Fix the mailboxes where username and alias matched.
foreach ($mailboxToRemoteEnable in $matchedUPNAliases) {
    $mailboxUsername = $mailboxToRemoteEnable.UserPrincipalName.Split('@')[0]
    $mailboxToFix = $mailboxToRemoteEnable.UserPrincipalName
    $remoteRoutingAddress = $mailboxUsername + $remoteRoutingSuffix
    Enable-OnPremRemoteMailbox -Identity $mailboxToFix -RemoteRoutingAddress $remoteRoutingAddress
}

# Write out the mailboxes that have been updated
Write-Output -InputObject ('The following mailboxes have been remote mail enabled.')
$matchedUPNAliases | Select-Object Name,Alias,UserPrincipalName,PrimarySmtpAddress

# Write out the mailboxes that have been left due to a mismatch between username and alias
Write-Output -InputObject ('The following mailboxes have not been changed because they have a mismatch between email alias and username.')
$mismatchedUPNAliases | Select-Object Name,Alias,UserPrincipalName,PrimarySmtpAddress

# End the 222.205.193.149 Session
Remove-PSSession -Session $session
}