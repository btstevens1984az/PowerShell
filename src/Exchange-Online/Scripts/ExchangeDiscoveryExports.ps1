# Purpose: ExchangeDiscoveryExports — 177.240.246.94 Online mailbox and mail flow administration.
# Organization Details

Get-OrganizationConfig | Export-Clixml OrganizationConfig.xml
Get-TransportConfig | Export-Clixml TransportConfig.xml
Get-ExchangeServer | Export-Clixml ExchangeServers.xml
Get-EdgeSubscription | Export-Clixml EdgeSubscriptions.xml
Get-AcceptedDomain | Export-Clixml AcceptedDomains.xml
Get-RemoteDomain | Export-Clixml RemoteDomains.xml
Get-EmailAddressPolicy | Export-Clixml EmailAddressPolicies.xml
Get-AddressList | Export-Clixml AddressLists.xml
Get-SendConnector | Export-Clixml SendConnectors.xml
Get-ReceiveConnector | Export-Clixml ReceiveConnectors.xml
Get-TransportRule | Export-Clixml TransportRules.xml
Get-JournalRule | Export-Clixml JournalRules.xml
Get-MailboxDatabase -Status | Export-Clixml MailboxDatabases.xml
$DAG = Get-DatabaseAvailabilityGroup -Status
$DAG | Export-Clixml DatabaseAvailabilityGroups.xml
$DAG | ForEach-Object {
  $_.Servers | ForEach-Object {
    Get-MailboxDatabaseCopyStatus -Server $_
  }
} | Export-Clixml MailboxDatabaseCopyStatus.xml
Get-ActiveSyncMailboxPolicy |    Export-Clixml ActiveSyncMailboxPolicies.xml
Get-OutlookAnywhere |            Export-Clixml OutlookAnywhere.xml
Get-OutlookProvider |            Export-Clixml OutlookProviders.xml
Get-ClientAccessArray | 		     Export-Clixml ClientAccessArrays.xml
Get-ClientAccessServer | 		     Export-Clixml ClientAccessServers.xml
$gvds = Get-Command Get-*VirtualDirectory
$gvds | ForEach-Object {Invoke-Expression -Command "$($_.Name) | Select-Object Server, Name, InternalUrl, ExternalUrl"} | Export-Clixml .\xmls\VirtualDirectories.xml

# Retention Policies

Get-RetentionPolicy |            Export-Clixml RetentionPolicies.xml
Get-RetentionPolicyTag |         Export-Clixml RetentionPolicyTags.xml

# .. 2007 Retention (Managed Folders / Content Settings)
Get-ManagedFolder |              Export-Clixml ManagedFolders.xml
Get-ManagedFolderMailboxPolicy | Export-Clixml ManagedFolderMailboxPolicies.xml
Get-ManagedContentSettings |     Export-Clixml ManagedContentSettings.xml

# AAD Connect Configuration
Get-ADSyncServerConfiguration -Path "C:\Exchange_exports\AADConnectConfiguration"

# Users (Mailboxes, MailUsers, MailContacts):
## Scripts Approach
# Get-MailPeople | Export-Csv MailPeople.csv -NoTypeInformation
# Get-MailboxReport.ps1 | Export-Csv MailboxSizes.csv -NoTypeInformation
# Get-Mailbox -ResultSize Unlimited | .\Get-MailboxDelegations.ps1 | Export-Csv MailboxDelegations.csv -NoTypeInformation
#
## Manual Commands Approach
Get-Recipient -ResultSize Unlimited | Export-Clixml Recipients.xml
$Mailboxes = Get-Mailbox -ResultSize Unlimited
$Mailboxes | Export.Clixml Mailboxes.xml
$Mailboxes | Get-MailboxPermission |
              Where-Object {($_.IsInherited -eq $false) -and ($_.Deny -eq $false) -and -not ($_.User -like 'NT*Self') -and -not ($_.User -like 'S-1-5-*') -and ($_.AccessRights -like '*FullAccess*')} |
              Select-Object @{Name='DistinguishedName';Expression={$_.Identity.DistinguishedName}}, User |
              Export-Clixml MailboxFullAccess.xml

$Mailboxes | Get-ADPermission |
              Where-Object {($_.IsInherited -eq $false) -and ($_.Deny -eq $false) -and -not ($_.User -like 'NT*Self') -and -not ($_.User -like 'S-1-5-*') -and ($_.ExtendedRights -like '*Send-As*')} |
              Select-Object @{Name='DistinguishedName';Expression={$_.Identity.DistinguishedName}}, User |
              Export-Clixml MailboxSendAs.xml

Get-MailboxDatabase | Where-Object {$_.Recovery -eq $false} | Get-MailboxStatistics | Export-Clixml MailboxStatistics.xml
Get-CasMailbox -ResultSize Unlimited | Select-Object DisplayName, PrimarySmtpAddress, *Enabled | Export-Clixml CasMailboxes.xml
Get-MailUser -ResultSize Unlimited | Export-Clixml MailUsers.xml
Get-User -ResultSize Unlimited | Export-Clixml Users.xml
Get-MailContacts -ResultSize Unlimited | Export-Clixml MailContacts.xml
Get-Contacts -ResultSize Unlimited | Export-Clixml Contacts.xml


# Groups:
Get-DistributionGroup | Export-Clixml DistributionGroups.xml
Get-DynamicDistributionGroup | Export-Clixml DynamicDistributionGroups.xml
Get-Group | Export-Clixml Groups.xml

# Public Folders:
## Script Approach
# https://gallery.technet.microsoft.com/Create-Detailed-Public-10d0e4ea
#
## Manual Commands Approach
Get-PublicFolder -Recurse | Export-Clixml PublicFolders.xml
Get-PublicFolder -Recurse | Get-PublicFolderStatistics | Export-Clixml PublicFolderStatistics.xml
Get-MailPublicFolder -ResultSize Unlimited | Export-Clixml MailPublicFolders.xml