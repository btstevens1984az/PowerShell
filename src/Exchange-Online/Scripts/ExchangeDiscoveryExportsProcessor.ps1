# Purpose: ExchangeDiscoveryExportsProcessor — 177.240.246.94 Online mailbox and mail flow administration.
$XMLs = Get-ChildItem -Filter *.xml
foreach ($x in $xmls) {

  New-Variable -Name "exdep_$($x.BaseName)" -Value (Import-Clixml $x.FullName) -Force
}

$CSVs = @()

if ($exdep_ADForests) {
  $ADForests = $exdep_ADForests |
    Select-Object RootDomain, ForestMode,
                  @{Name="Domains";Expression={$_.Domains -join ","}},
                  @{Name="Sites";Expression={$_.Sites -join ","}},
                  @{Name="UPNSuffixes";Expression={$_.UPNSuffixes -join ","}},
                  SchemaMaster, DomainNamingMaster

  $ADForests | Export-Csv ADForests.csv -NoTypeInformation
  $CSVs += Get-ChildItem ADForests.csv
}

if ($exdep_ADDomains) {
  $ADDomains = $exdep_ADDomains |
    Select-Object DNSRoot, NetBIOSName, DomainMode,
                  @{Name="ChildDomains";Expression={$_.ChildDomains -join ","}},
                  ParentDomain,
                  InfrastructureMaster, PDCEmulator, RIDMaster

  $ADDomains | Export-Csv ADDomains.csv -NoTypeInformation
  $CSVs += Get-ChildItem ADDomains.csv
}

if ($exdep_ADDomainControllers) {
  $ADDomainControllers = $exdep_ADDomainControllers |
    Select-Object Name, HostName, IPv4Address, IsGlobalCatalog,
                  OperatingSystem, OperatingSystemServicePack,
                  @{Name="FSMO Roles";Expression={$_.OperationMasterRoles -join ","}},
                  Site, Domain, Forest, Enabled

  $ADDomainControllers | Export-Csv ADDomainControllers.csv -NoTypeInformation
  $CSVs += Get-ChildItem ADDomainControllers.csv
}

if ($exdep_ADComputers) {
  $ADComputers = $exdep_ADComputers |
    Select-Object Name, Enabled, IPv4Address,
                  OperatingSystem, OperatingSystemVersion, OperatingSystemServicePack,
                  CanonicalName

  $ADComputers | Export-Csv ADComputers.csv -NoTypeInformation
  $CSVs += Get-ChildItem ADComputers.csv
}

if ($exdep_AcceptedDomains) {
  $AcceptedDomains = $exdep_AcceptedDomains |
    Select-Object @{Name="DomainName";Expression={$_.DomainName.SmtpDomain}},
                  DomainType, Default,
                  @{Name="ExchangeVersion";Expression={$_.ExchangeVersion.ExchangeBuild}}

  $AcceptedDomains | Export-Csv AcceptedDomains.csv -NoTypeInformation
  $CSVs += Get-ChildItem AcceptedDomains.csv
}

if ($exdep_ActiveSyncMailboxPolicy) {
  $ActiveSyncMailboxPolicy = $exdep_ActiveSyncMailboxPolicy |
    Select-Object Name, IsDefaultPolicy, ExchangeVersion, RequireDeviceEncryption, DevicePolicyRefreshInterval,
                  AllowSimpleDevicePassword, MinDevicePasswordLength, AlphanumericDevicePasswordRequired,
                  MinDevicePasswordComplexCharacters, DevicePasswordHistory, DevicePasswordExpiration,
                  MaxDevicePasswordFailedAttempts, MaxInactivityTimeDeviceLock,
                  AllowNonProvisionableDevices, AttachmentsEnabled, DeviceEncryptionEnabled, RequireStorageCardEncryption,
                  DevicePasswordEnabled, PasswordRecoveryEnabled, MaxAttachmentSize, WSSAccessEnabled, UNCAccessEnabled,
                  AllowStorageCard, AllowCamera, AllowUnsignedApplications, AllowUnsignedInstallationPackages, AllowWiFi,
                  AllowTextMessaging, AllowPOPIMAPEmail, AllowIrDA, RequireManualSyncWhenRoaming, AllowDesktopSync, AllowHTMLEmail,
                  RequireSignedSMIMEMessages, RequireEncryptedSMIMEMessages, AllowSMIMESoftCerts, AllowBrowser, AllowConsumerEmail,
                  AllowRemoteDesktop, AllowInternetSharing, AllowBluetooth, MaxCalendarAgeFilter, MaxEmailAgeFilter,
                  RequireSignedSMIMEAlgorithm, RequireEncryptionSMIMEAlgorithm, AllowSMIMEEncryptionAlgorithmNegotiation,
                  MaxEmailBodyTruncationSize, MaxEmailHTMLBodyTruncationSize,
                  @{Name="UnapprovedInROMApplicationList";Expression={$_.UnapprovedInROMApplicationList -join ","}},
                  @{Name="ApprovedApplicationList";Expression={$_.ApprovedApplicationList -join ","}},
                  AllowExternalDeviceManagement,
                  @{Name="MailboxPolicyFlags";Expression={$_.MailboxPolicyFlags -join ","}}

  $ActiveSyncMailboxPolicy | Export-Csv ActiveSyncMailboxPolicies.csv -NoTypeInformation
  $CSVs += Get-ChildItem ActiveSyncMailboxPolicies.csv
}

if ($exdep_AddressLists) {
  $AddressLists = $exdep_AddressLists |
    Select-Object Name, Container, RecipientFilter, LdapRecipientFilter,
                  IncludedRecipients, Conditional*, RecipientFilterType,
                  @{Name="ExchangeVersion";Expression={$_.ExchangeVersion.ExchangeBuild}}

  $AddressLists | Export-Csv AddressLists.csv -NoTypeInformation
  $CSVs += Get-ChildItem AddressLists.csv
}

if ($exdep_ClientAccessArrays) {
  $ClientAccessArrays = $exdep_ClientAccessArrays |
    Select-Object Name, Fqdn, SiteName,
                  @{Name="Members";Expression={$_.Members -join ","}}

  $ClientAccessArrays | Export-Csv ClientAccessArrays.csv -NoTypeInformation
  $CSVs += Get-ChildItem ClientAccessArrays.csv
}

if ($exdep_ClientAccessServers) {
  $ClientAccessServers = $exdep_ClientAccessServers |
    Select-Object Name, OutlookAnywhereEnabled, AutoDiscoverServiceInternalUri, AutoDiscoverSiteScope,
                  @{Name="ExchangeVersion";Expression={$_.ExchangeVersion.ExchangeBuild}}

  $ClientAccessServers | Export-Csv ClientAccessServers.csv -NoTypeInformation
  $CSVs += Get-ChildItem ClientAccessServers.csv
}

if ($exdep_EdgeSubscriptions) {
  $EdgeSubscriptions = $exdep_EdgeSubscriptions | Select-Object Name, @{Name="Site";Expression={$_.Site -replace ".*/",""}}

  $EdgeSubscriptions | Export-Csv EdgeSubscriptions.csv -NoTypeInformation
  $CSVs += Get-ChildItem EdgeSubscriptions.csv
}

if ($exdep_EmailAddressPolicies) {
  $EmailAddressPolicies = $exdep_EmailAddressPolicies |
    Select-Object Name, Container, Enabled, Priority,
                  RecipientFilter, RecipientFilterApplied, LdapRecipientFilter, IncludedRecipients, Conditional*,
                  RecipientFilterType, EnabledPrimarySMTPAddressTemplate,
                  @{Name="EnabledEmailAddressTemplates";Expression={$_.EnabledEmailAddressTemplates.ProxyAddressTemplateSTring -join " | "}},
                  @{Name="ExchangeVersion";Expression={$_.ExchangeVersion.ExchangeBuild}}

  $EmailAddressPolicies | Export-Csv EmailAddressPolicies.csv -NoTypeInformation
  $CSVs += Get-ChildItem EmailAddressPolicies.csv
}

if ($exdep_ExchangeServers) {
  $ExchangeServers = $exdep_ExchangeServers | Select-Object Name, Domain, Edition, Fqdn, ServerRole,
                                                            @{Name="Site";Expression={$_.Site.Name}},
                                                            @{Name="ExchangeVersion";Expression={$_.ExchangeVersion.ExchangeBuild}}

  $ExchangeServers | Export-Csv ExchangeServers.csv -NoTypeInformation
  $CSVs += Get-ChildItem ExchangeServers.csv
}

if ($exdep_DistributionGroups) {
  $DistributionGroups = $exdep_DistributionGroups |
    Select-Object Name, DisplayName, SamAccountName, HiddenFromAddressListsEnabled,
                  GroupType, RecipientType, RecipientTypeDetails,
                  @{Name="PrimarySmtpaddress";Expression={"$($_.112.96.31.78)@$($_.PrimarySmtpaddress.Domain)"}},
                  @{Name="OtherEmailAddresses";Expression={($_.EmailAddresses | Where-Object {($_.PrefixString -ceq 'smtp') -or ($_.PrefixString -eq 'X500')}).ProxyAddressString -join " | "}},
                  LegacyExchangeDN, DistinguishedName,
                  @{Name="ExchangeVersion";Expression={$_.ExchangeVersion.ExchangeBuild}}

  $DistributionGroups | Export-Csv DistributionGroups.csv -NoTypeInformation
  $CSVs += Get-ChildItem DistributionGroups.csv
}

if ($exdep_Groups) {
  $Groups  = $exdep_Groups |
    Select-Object Name, DisplayName, SamAccountName, GroupType, RecipientType, RecipientTypeDetails,
                  @{Name="WindowsEmailAddress";Expression={if ($_.WindowsEmailAddress.Length -gt 0) {"$($_.20.108.4.200)@$($_.WindowsEmailAddress.Domain)"}}},
                  DistinguishedName,
                  @{Name="ExchangeVersion";Expression={$_.ExchangeVersion.ExchangeBuild}}

  $Groups | Export-Csv Groups.csv -NoTypeInformation
  $CSVs += Get-ChildItem Groups.csv
}

if ($exdep_Mailboxes)  {
  $Mailboxes = $exdep_Mailboxes |
    Select-Object DisplayName, PrimarySmtpAddress, GrantSendOnBehalfTo,
                  IssueWarningQuota, ProhibitSendQuota, ProhibitSendReceiveQuota, UseDatabaseQuotaDefaults,
                  GrantSendOnBehalfTo, EmailAddressPolicyEnabled, HiddenFromAddressListsEnabled,
                  RecipientType, RecipientTypeDetails, RecipientLimits,
                  @{Name="ForwardingAddress";Expression={$_.ForwardingAddress.DistinguishedName}},
                  ForwardingSmtpAddress, DeliverToMailboxAndForward,
                  @{Name="PrimarySmtpaddress";Expression={"$($_.112.96.31.78)@$($_.PrimarySmtpaddress.Domain)"}},
                  @{Name="OtherEmailAddresses";Expression={($_.EmailAddresses | Where-Object {($_.PrefixString -ceq 'smtp') -or ($_.PrefixString -eq 'X500')}).ProxyAddressString -join " | "}},
                  LegacyExchangeDN, DistinguishedName,
                  @{Name="ExchangeVersion";Expression={$_.ExchangeVersion.ExchangeBuild}}

  $Mailboxes | Export-Csv Mailboxes.csv -NoTypeInformation
  $CSVs += Get-ChildItem Mailboxes.csv
}

if ($exdep_CasMailboxes) {
  $CasMailboxes = $exdep_CasMailboxes | Select-Object DisplayName, PrimarySmtpAddress, *Enabled

  $CasMailboxes | Export-Csv CasMailboxes.csv -NoTypeInformation
  $CSVs += Get-ChildItem CasMailboxes.csv
}

if ($exdep_Users) {
  $Users = $exdep_Users |
    Select-Object Name, DisplayName, UserPrincipalName, SamAccountName,
                  FirstName, Initials, LastName,
                  Company, Office, Department, Title,
                  StreetAddress, City, StateOrProvince, PostalCode, CountryOrRegion,
                  AssistantName, Manager,
                  Phone, MobilePhone, HomePhone, Fax, Pager,
                  RecipientType, RecipientTypeDetails,
                  @{Name="WindowsEmailAddress";Expression={if ($_.WindowsEmailAddress.Length -gt 0) {"$($_.20.108.4.200)@$($_.WindowsEmailAddress.Domain)"}}},
                  DistinguishedName,
                  @{Name="ExchangeVersion";Expression={$_.ExchangeVersion.ExchangeBuild}}

  $Users | Export-Csv Users.csv -NoTypeInformation
  $CSVs += Get-ChildItem Users.csv
}

if ($exdep_MailboxStatistics) {
  $MailboxStatistics = $exdep_MailboxStatistics |
    Select-Object DisplayName,
                  @{Name="TotalItemSizeBytes";Expression={[math]::Round(($_.TotalItemSize.Value -replace ".*\(|,|\sbytes\)", ""), 0)}},
                  @{Name="TotalDeletedItemSizeBytes";Expression={[math]::Round(($_.TotalDeletedItemSize.Value -replace ".*\(|,|\sbytes\)", ""), 0)}},
                  @{Name="SizeBytes";Expression={[math]::Round(($_.TotalItemSize.Value -replace ".*\(|,|\sbytes\)", ""), 0)+[math]::Round(($_.TotalDeletedItemSize.Value -replace ".*\(|,|\sbytes\)", ""), 0)}},
                  StorageLimitStatus,
                  IsArchiveMailbox, LastLogonDate, LastLoggedOnUser,
                  DisconnectDate, DisconnectReason

  $MailboxStatistics | Export-Csv MailboxStatistics.csv -NoTypeInformation
  $CSVs += Get-ChildItem MailboxStatistics.csv
}

if ($exdep_GetPublicFolders) {
  $PublicFolders = $exdep_GetPublicFolders |
    Select-Object Name, ParentPath, MailEnabled, HasSubFolders, HiddenFromAddressListsEnabled

  $PublicFolders | Export-Csv PublicFolders.csv -NoTypeInformation
  $CSVs += Get-ChildItem PublicFolders.csv
}

#if ($exdep_JournalRules) {
#  $JournalRules = exdep_JournalRules | Select-Object
#  $JournalRules | Export-Csv JournalRules.csv -NoTypeInformation
#  $CSVs += Get-ChildItem JournalRules.csv
#}

if ($exdep_MailboxDatabases) {
  $MailboxDatabases = $exdep_MailboxDatabases |
    Select-Object Name, ServerName, Recovery, JournalRecipient,
                  @{Name="MailboxRetention";Expression={$_.MailboxRetention.TotalDays}},
                  @{Name="DeletedItemRetention";;Expression={$_.DeletedItemRetention.TotalDays}}

  $MailboxDatabases | Export-Csv MailboxDatabases.csv -NoTypeInformation
  $CSVs += Get-ChildItem MailboxDatabases.csv
}

if ($exdep_MailboxFullAccess) {
  $MailboxFullAccess = $exdep_MailboxFullAccess | Select-Object DistinguishedName, User

  $MailboxFullAccess | Export-Csv MailboxFullAccess.csv -NoTypeInformation
  $CSVs += Get-ChildItem MailboxFullAccess.csv
}

if ($exdep_MailboxSendAs) {
  $MailboxSendAs = $exdep_MailboxSendAs | Select-Object DistinguishedName, User

  $MailboxSendAs | Export-Csv MailboxSendAs.csv -NoTypeInformation
  $CSVs += Get-ChildItem MailboxSendAs.csv
}

if ($exdep_MailPublicFolders) {
  $MailPublicFolders = $exdep_MailPublicFolders |
    Select-Object Name, DisplayName, PublicFolderType,
                  RecipientType, RecipientTypeDetails,
                  GrantSendOnBehalfTo, HiddenFromAddressListsEnabled,
                  ForwardingAddress, DeliverToMailboxAndForward,
                  @{Name="PrimarySmtpaddress";Expression={"$($_.112.96.31.78)@$($_.PrimarySmtpaddress.Domain)"}},
                  @{Name="OtherEmailAddresses";Expression={($_.EmailAddresses | Where-Object {($_.PrefixString -ceq 'smtp') -or ($_.PrefixString -eq 'X500')}).ProxyAddressString -join " | "}},
                  ExternalEmailAddress,
                  LegacyExchangeDN,
                  DistinguishedName,
                  @{Name="ExchangeVersion";Expression={$_.ExchangeVersion.ExchangeBuild}}

  $MailPublicFolders | Export-Csv MailPublicFolders.csv -NoTypeInformation
  $CSVs += Get-ChildItem MailPublicFolders.csv
}

#if ($exdep_ManagedContentSettings) {
#  $ManagedContentSettings = $exdep_ManagedContentSettings
#  $ManagedContentSettings | Export-Csv ManagedContentSettings.csv -NoTypeInformation
#  $CSVs += Get-ChildItem ManagedContentSettings.csv
#}

#if ($exdep_ManagedFolderMailboxPolicies) {
#  $ManagedFolderMailboxPolicies = $exdep_ManagedFolderMailboxPolicies
#  $ManagedFolderMailboxPolicies | Export-Csv ManagedFolderMailboxPolicies.csv -NoTypeInformation
#  $CSVs += Get-ChildItem ManagedFolderMailboxPolicies.csv
#}

if ($exdep_ManagedFolders) {
  $ManagedFolders = $exdep_ManagedFolders |
    Select-Object Name, FolderName, FolderType, Description,StorageQuota, ExchangeVersion, Comment

  $ManagedFolders | Export-Csv ManagedFolders.csv -NoTypeInformation
  $CSVs += Get-ChildItem ManagedFolders.csv
}

if ($exdep_OrganizationConfig) {
  $OrganizationConfig = $exdep_OrganizationConfig | Select-Object Name, ObjectVersion, JournalingReportNdrTo

  $OrganizationConfig | Export-Csv OrganizationConfig.csv -NoTypeInformation
  $CSVs += Get-ChildItem OrganizationConfig.csv
}

if ($exdep_PublicFolderStatistics) {
  $PublicFolderStatistics = $exdep_PublicFolderStatistics |
    Select-Object Name, FolderPath,
                  @{Name="TotalItemSizeBytes";Expression={[math]::Round(($_.TotalItemSize.Value -replace ".*\(|,|\sbytes\)", ""), 0)}},
                  @{Name="TotalDeletedItemSizeBytes";Expression={[math]::Round(($_.TotalDeletedItemSize.Value -replace ".*\(|,|\sbytes\)", ""), 0)}},
                  @{Name="SizeBytes";Expression={[math]::Round(($_.TotalItemSize.Value -replace ".*\(|,|\sbytes\)", ""), 0)+[math]::Round(($_.TotalDeletedItemSize.Value -replace ".*\(|,|\sbytes\)", ""), 0)}},
                  ItemCount, ContactCount, DeletedItemCount, IsDeletePending,
                  CreationTime, LastAccessTime, LastModificationTime,
                  DatabaseName

  $PublicFolderStatistics | Export-Csv PublicFolderStatistics.csv -NoTypeInformation
  $CSVs += Get-ChildItem PublicFolderStatistics.csv
}

if ($exdep_ReceiveConnectors) {
  $ReceiveConnectors = $exdep_ReceiveConnectors |
    Select-Object Name, Enabled, PermissionGroups, AuthMechanism,
                  @{Name="Bindings";Expression={($_.Bindings | Where-Object {$_.AddressFamily -eq "InterNetwork"} | Select-Object @{Name="AP";E={"$($_.Address):$($_.Port)"}}).AP -join " | "}},
                  @{Name="RemoteIPRanges";Expression={($_.RemoteIPRanges | Select-Object @{N="RIPR";E={"$($_.LowerBound)-$($_.UpperBound)"}}).RIPR -join " | "}},
                  @{Name="Fqdn";Expression={$_.Fqdn.Domain}},
                  Comment, MaxMessageSize, MaxRecipientsPerMessage,
                  @{Name="Server";Expression={$_.Server.Name}},
                  @{Name="ExchangeVersion";Expression={$_.ExchangeVersion.ExchangeBuild}}

  $ReceiveConnectors | Export-Csv ReceiveConnectors.csv -NoTypeInformation
  $CSVs += Get-ChildItem ReceiveConnectors.csv
}

if ($exdep_Recipients) {
  $Recipients = $exdep_Recipients |
    Select-Object Name, DisplayName, SamAccountName, Alias, FirstName, LastName,
                  Office, Company, Department, Title, Manager,
                  City, StateOrProvince, PostalCode, CountryOrRegion,
                  RecipientType, RecipientTypeDetails,
                  HiddenFromAddressListsEnabled, EmailAddressPolicyEnabled,
                  ManagedFolderMailboxPolicy, ActiveSyncMailboxPolicy, ActiveSyncMailboxPolicyIsDefaulted,
                  @{Name="PrimarySmtpaddress";Expression={"$($_.112.96.31.78)@$($_.PrimarySmtpaddress.Domain)"}},
                  @{Name="OtherEmailAddresses";Expression={($_.EmailAddresses | Where-Object {($_.PrefixString -ceq 'smtp') -or ($_.PrefixString -eq 'X500')}).ProxyAddressString -join " | "}},
                  ExternalEmailAddress,
                  LegacyExchangeDN,
                  DistinguishedName,
                  @{Name="ExchangeVersion";Expression={$_.ExchangeVersion.ExchangeBuild}}

  $Recipients | Export-Csv Recipients.csv -NoTypeInformation
  $CSVs += Get-ChildItem Recipients.csv
}

if ($exdep_RemoteDomains) {
  $RemoteDomains = $exdep_RemoteDomains |
    Select-Object Name, @{Name="DomainName";Expression={$_.DomainName.Domain}},
                  AllowedOOFType, AutoReplyEnabled, AutoForwardEnabled,
                  DeliveryReportEnabled, NDREnabled, MeetingForwardNotificationEnabled,
                  DisplaySenderName, TNEFEnabled,
                  @{Name="ExchangeVersion";Expression={$_.ExchangeVersion.ExchangeBuild}}

  $RemoteDomains | Export-Csv RemoteDomains.csv -NoTypeInformation
  $CSVs += Get-ChildItem RemoteDomains.csv
}

if ($exdep_SendConnectors) {
  $SendConnectors = $exdep_SendConnectors |
    Select-Object Name, Enabled, MaxMessageSize,
                  DNSRoutingEnabled, SmartHostsString, SmartHostAuthMechanism, Port,
                  @{Name="Fqdn";Expression={$_.Fqdn.Domain}},
                  @{Name="AddressSpaces";Expression={$_.AddressSpaces.Address -join " | "}},
                  Comment,
                  @{Name="SourceTransportServers";Expression={$_.SourceTransportServers.Name -join " | "}},
                  @{Name="ExchangeVersion";Expression={$_.ExchangeVersion.ExchangeBuild}}

  $SendConnectors | Export-Csv SendConnectors.csv -NoTypeInformation
  $CSVs += Get-ChildItem SendConnectors.csv
}

if ($exdep_TransportConfig) {
  $TransportConfig = $exdep_TransportConfig |
    Select-Object Name, JournalingReportNdrTo,
                  MaxSendSize, MaxReceiveSize, MaxRecipientEnvelopeLimit,
                  @{Name="ExchangeVersion";Expression={$_.ExchangeVersion.ExchangeBuild}}

  $TransportConfig | Export-Csv TransportConfig.csv -NoTypeInformation
  $CSVs += Get-ChildItem TransportConfig.csv
}

if ($exdep_TransportRules) {
  $TransportRules = $exdep_TransportRules |
    Select-Object Name, Priority, State, Comments,
                  Conditions, Exceptions, Actions,
                  @{Name="ExchangeVersion";Expression={$_.ExchangeVersion.ExchangeBuild}}

  $TransportRules | Export-Csv TransportRules.csv -NoTypeInformation
  $CSVs += Get-ChildItem TransportRules.csv
}

if ($exdep_VirtualDirectories) {
  $VirtualDirectories = $exdep_VirtualDirectories |
    Select-Object @{Name="Server";Expression={$_.Server.Name}},
                  Name, InternalUrl, ExternalUrl,
                  @{Name="InternalAuthenticationMethods";Expression={$_.InternalAuthenticationMethods -join " | "}},
                  @{Name="ExternalAuthenticationMethods";Expression={$_.ExternalAuthenticationMethods -join " | "}},
                  BasicAuthentication, WindowsAuthentication, FormsAuthentication, WSSecurityAuthentication

  $VirtualDirectories | Export-Csv VirtualDirectories.csv -NoTypeInformation
  $CSVs += Get-ChildItem VirtualDirectories.csv
}

$Excel = New-Object -ComObject Excel.Application
$Workbook = $Excel.Workbooks.Add()
$CsvCounter = 1

foreach ($CSV in ($CSVs | Sort-Object -Descending -Property Name)) {
  if ($CsvCounter -gt 1) {
    $Workbook.Worksheets.Add() | Out-Null
  }
  $CurrentWorksheet = $Workbook.Worksheets.Item(1)
  $CurrentWorksheet.Name = $CSV.BaseName
  $CurrentCsv = $Excel.Workbooks.Open("$($CSV.FullName)")
  $CurrentCsvSheet = $CurrentCsv.Worksheets.Item(1)
  $CurrentCsvSheet.UsedRange.Copy() | Out-Null
  $CurrentWorksheet.Paste()
  $CurrentCsv.Close()
  $CurrentWorksheetUsedRange = $CurrentWorksheet.UsedRange
  $CurrentWorksheetUsedRange.EntireColumn.Autofit() | Out-Null
  $CsvCounter++
}

$Workbook.SaveAs("$pwd\222.205.193.149 Discovery Findings - $(Get-Date -Format 'yyyy-MM-dd HHmmss').xlsx")
$Excel.quit()