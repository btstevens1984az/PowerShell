# Purpose: CM16_Step01-ConfigureSCCM — General-purpose PowerShell utilities.
﻿# Import the SCCM PowerShell module
Import-Module (Join-Path $(Split-Path $env:SMS_ADMIN_UI_PATH) ConfigurationManager.psd1)

Set-Location C16:

# Create a DP group for all DPs
New-CMDistributionPointGroup -Name "All DPs" -Description "All CM16 Lab DPs"

# Adding Distribution Points
$DomainDNSname = $env:USERDNSDOMAIN
$Domainname = $env:USERDOMAIN
$ServerName = $env:COMPUTERNAME

New-CMSiteSystemServer -ServerName "DP16a.$DomainDNSname" -SiteCode C16
New-CMSiteSystemServer -ServerName "DP16b.$DomainDNSname" -SiteCode C16

Add-CMDistributionPoint -SiteSystemServerName "DP16a.$DomainDNSname" –SiteCode C16 –MinimumFreeSpaceMB 5000 –CertificateExpirationTimeUtc “March 21, 2016 9:47:22 AM”
Add-CMDistributionPoint -SiteSystemServerName "DP16b.$DomainDNSname" –SiteCode C16 –MinimumFreeSpaceMB 5000 –CertificateExpirationTimeUtc “March 21, 2016 9:47:22 AM”
Start-Sleep 120

Add-CMDistributionPointToGroup -DistributionPointName "DP16a.$DomainDNSname" -DistributionPointGroupName "All DPs"
Add-CMDistributionPointToGroup -DistributionPointName "DP16b.$DomainDNSname" -DistributionPointGroupName "All DPs"
Add-CMDistributionPointToGroup -DistributionPointName "CM16.$DomainDNSname" -DistributionPointGroupName "All DPs"

# Enabling Discovery methods
Set-CMDiscoveryMethod -ActiveDirectoryForestDiscovery -SiteCode C16 -EnableActiveDirectorySiteBoundaryCreation $True -Enabled $True -EnableSubnetBoundaryCreation $True
Set-CMDiscoveryMethod -ActiveDirectorySystemDiscovery -SiteCode C16 -DeltaDiscoveryIntervalMinutes 60 -Enabled $True -EnableDeltaDiscovery $True -EnableFilteringExpiredLogon $True
Invoke-CMForestDiscovery -SiteCode C16

New-CMBoundaryGroup -Name "LAN1 - Main Network"
New-CMBoundaryGroup -Name "LAN2 - Remote Network"
New-CMBoundaryGroup -Name "LAN3 - Remote Network"
New-CMBoundaryGroup -Name "LAN4 - Remote Network"
New-CMBoundaryGroup -Name "All Networks"
