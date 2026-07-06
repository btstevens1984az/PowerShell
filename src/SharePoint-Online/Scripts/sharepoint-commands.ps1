# Purpose: sharepoint-commands — SharePoint Online site administration.
$site="https://domain.sharepoint.com/sites/corpcomm"

#Installing Powershell module

install-module -name Microsoft.Online.Sharepoint.PowersShell
Install-Module -Name SharepointPnpPowershellOnline

#connecting to sharepoint online. With PNP module, we can connect to specific site collection

Connect-SPOService -Url https://domain-admin.sharepoint.com
Connect-PnPOnline -Url https://domain-admin.sharepoint.com -UseWebLogin

#Get list of sharepoint sites
Get-SPOSite

#creating teams site not connected to office365 group
New-SPOSite -Owner user@domain.onmicrosoft.com -Title "Frm Powershell-Teams site without 365 group" -Template STS#3 -StorageQuota 1024 -Url https://domain.sharepoint.com/sites/teamsitewithout365group
#Creating communications site
New-SPOSite -Owner user@domain.onmicrosoft.com -Title "Frm Powershell-Teams site without 365 group" -Template sitepagepublishing#0 -StorageQuota 1024 -Url https://domain.sharepoint.com/sites/teamsitewithout365group

#creating teams site connected to office365 group. Alias is the shared mailbox email address + makes up the URL /sites/alias
New-PnPSite -Type TeamSite -Title "PNP Site- With office365group" -Alias "pnpsitealias"

New-PnPSite -Type CommunicationSite -Title "PNP Site- Communication site" -Url "https://domain.sharepoint.com/sites/corpcomm" -SiteDesign Showcase

# Get all properties of site to know which settings can be changed. Few things like site template can not be changed
Get-SPOSite -Identity https://domain.sharepoint.com/sites/teamsiteUI1 | Select-Object *
#Rename site name and URL
Start-SPOSiteRename -Identity https://domain.sharepoint.com/sites/teamsiteUI1 -NewSiteTitle "Teams site from GUI" -NewSiteUrl https://domain.sharepoint.com/sites/teamssitegromgui
#Disable social bar on site pages
Set-SPOSite -Identity https://domain.sharepoint.com/sites/teamsitegromgui -SocialBarOnSitePagesDisabled $true

#Change primary site admin
Set-SPOSite -Identity $site -Owner username@domain.com

#Add site admin
Set-SPOUser -Site $site -LoginName user@domain -IsSiteCollectionAdmin $false

#set sharing settings for a site
Set-SPOSite -Identity $site -DefaultLinkPermission View -DefaultSharingLinkType Internal -SharingCapability ExternalUserAndGuestSharing -ShowPeoplePickerSuggestionsForGuestUsers $true

# block domains for external sharing
Set-SPOSite -Identity $site -SharingDomainRestrictionMode BlockList -SharingBlockedDomainList "domain.com"


#deleting site. If site is associated with office365 group, delete the group first
Remove-SPOSite -Identity $site

#Recovering site from recycle bin
Restore-SPODeletedSite -Identity $site

#deleting site from recycle bin
Remove-SPODeletedSite -Identity $site

#registering site as hub
Register-SPOHubSite -Site $site -Principals user@domain.onmicrosoft.com,user@domain

#grant permissions
Grant-SPOHubSiteRights -Identity $site -Principals user@domain -Rights Join

#Associate site with hub sites
Add-SPOHubSiteAssociation -Site $site -HubSite $hub

#Removing site from hub association .. rights can also be revoked
Remove-SPOHubSiteAssociation -Site https://domain.sharepoint.com/sites/teamsitegromgui

#Unregistering hub site
Unregister-SPOHubSite -Identity $site


#EXTERNAL SHARING - Add bcc address for all external invitations
Set-SPOTenant -BccExternalSharingInvitations $true -BccExternalSharingInvitationsList user@domain.com
