# Purpose: Create-Collection2017AD Sites — Configuration Manager collections and deployments.

#
# Version : 2.8


#Load Configuration Manager PowerShell Module
Import-module ($Env:SMS_ADMIN_UI_PATH.Substring(0,$Env:SMS_ADMIN_UI_PATH.Length-5) + '\ConfigurationManager.psd1')

#Get SiteCode
$SiteCode = Get-PSDrive -PSProvider CMSITE
Set-location $SiteCode":"

#Error Handling and output
Clear-Host
$ErrorActionPreference= 'SilentlyContinue'
$Error1 = 0

#Refresh Schedule
$Schedule = New-CMSchedule –RecurInterval Days –RecurCount 21

#List of Collections Query
$Collection1 = @{Name = "BAT All Systems"; Query =  "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ADSiteName = 'BAT'"}
$Collection2 = @{Name = "BMH All Systems"; Query =  "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ADSiteName = 'BMH'"}
$Collection3 = @{Name = "BNI All Systems"; Query =  "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ADSiteName = 'BNI'"}
$Collection4 = @{Name = "CHC All Systems"; Query =  "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ADSiteName = 'CHC'"}
$Collection5 = @{Name = "COR All Systems"; Query =  "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ADSiteName = 'COr'"}
$Collection6 = @{Name = "CRH All Systems"; Query =  "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ADSiteName = 'CRH'"}
$Collection7 = @{Name = "CSB All Systems"; Query =  "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ADSiteName = 'CSB'"}
$Collection8 = @{Name = "DHM All Systems"; Query =  "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ADSiteName = 'DHM'"}
$Collection9 = @{Name = "DMF All Systems"; Query =  "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ADSiteName = 'DMF'"}
$Collection10 = @{Name = "DSC All Systems"; Query =  "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ADSiteName = 'DSC'"}
$Collection11 = @{Name = "EDC All Systems"; Query =  "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ADSiteName = 'EDC'"}
$Collection12 = @{Name = "FHM All Systems"; Query =  "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ADSiteName = 'FHM'"}
$Collection13 = @{Name = "GMH All Systems"; Query =  "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ADSiteName = 'GMH'"}
$Collection14 = @{Name = "IHO All Systems"; Query =  "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ADSiteName = 'IHO'"}
$Collection15 = @{Name = "LS4_CHWCA All Systems"; Query =  "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ADSiteName = 'LS4_CHWCA'"}
$Collection16 = @{Name = "LVS All Systems"; Query =  "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ADSiteName = 'LVS'"}
$Collection17 = @{Name = "MCC All Systems"; Query =  "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ADSiteName = 'MCC'"}
$Collection18 = @{Name = "MCM All Systems"; Query =  "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ADSiteName = 'MCM'"}
$Collection19 = @{Name = "MET All Systems"; Query =  "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ADSiteName = 'MET'"}
$Collection20 = @{Name = "MGC All Systems"; Query =  "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ADSiteName = 'MGC'"}
$Collection21 = @{Name = "MGH All Systems"; Query =  "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ADSiteName = 'MGH'"}
$Collection22 = @{Name = "MHB All Systems"; Query =  "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ADSiteName = 'MHB'"}
$Collection23 = @{Name = "MHF All Systems"; Query =  "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ADSiteName = 'MHF'"}
$Collection24 = @{Name = "MIC All Systems"; Query =  "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ADSiteName = 'MIC'"}
$Collection25 = @{Name = "MMC All Systems"; Query =  "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ADSiteName = 'MMC'"}

$Collection26 = @{Name = "MMR All Systems"; Query =  "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ADSiteName = 'MMR'"}
$Collection27 = @{Name = "MMS All Systems"; Query =  "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ADSiteName = 'MMS'"}
$Collection28 = @{Name = "MSH All Systems"; Query =  "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ADSiteName = 'MSH'"}
$Collection29 = @{Name = "MSJ All Systems"; Query =  "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ADSiteName = 'MSJ'"}
$Collection30 = @{Name = "MTC All Systems"; Query =  "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ADSiteName = 'MTC'"}
$Collection31 = @{Name = "NHC All Systems"; Query =  "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ADSiteName = 'NHC'"}
$Collection32 = @{Name = "PAS All Systems"; Query =  "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ADSiteName = 'PAS'"}
$Collection33 = @{Name = "SITE01 All Systems"; Query =  "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ADSiteName = 'SITE01'"}
$Collection34 = @{Name = "SAC All Systems"; Query =  "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ADSiteName = 'SAC'"}
$Collection35 = @{Name = "SAC2 All Systems"; Query =  "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ADSiteName = 'SAC2'"}
$Collection36 = @{Name = "SAC3 All Systems"; Query =  "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ADSiteName = 'SAC3'"}

$Collection37 = @{Name = "SBM All Systems"; Query =  "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ADSiteName = 'SBM'"}
$Collection38 = @{Name = "SEH All Systems"; Query =  "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ADSiteName = 'SEH'"}
$Collection39 = @{Name = "SEQ All Systems"; Query =  "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ADSiteName = 'SEQ'"}
$Collection40 = @{Name = "SFH All Systems"; Query =  "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ADSiteName = 'SFH'"}
$Collection41 = @{Name = "SJB All Systems"; Query =  "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ADSiteName = 'SJB'"}
$Collection42 = @{Name = "SJH All Systems"; Query =  "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ADSiteName = 'SJH'"}
$Collection43 = @{Name = "SJM All Systems"; Query =  "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ADSiteName = 'SJM'"}
$Collection44 = @{Name = "SJP All Systems"; Query =  "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ADSiteName = 'SJP'"}
$Collection45 = @{Name = "SJR All Systems"; Query =  "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ADSiteName = 'SJR'"}
$Collection46 = @{Name = "SJW All Systems"; Query =  "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ADSiteName = 'SJW'"}
$Collection47 = @{Name = "SML All Systems"; Query =  "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ADSiteName = 'SML'"}

$Collection48 = @{Name = "SMR All Systems"; Query =  "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ADSiteName = 'SMR'"}
$Collection49 = @{Name = "SMS All Systems"; Query =  "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ADSiteName = 'SMS'"}
$Collection50 = @{Name = "SNM All Systems"; Query =  "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ADSiteName = 'SNM'"}
$Collection51 = @{Name = "SRD All Systems"; Query =  "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ADSiteName = 'SRD'"}
$Collection52 = @{Name = "SRM All Systems"; Query =  "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ADSiteName = 'SRM'"}
$Collection53 = @{Name = "SRS All Systems"; Query =  "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ADSiteName = 'SRS'"}
$Collection54 = @{Name = "UAC All Systems"; Query =  "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ADSiteName = 'UAC'"}
$Collection55 = @{Name = "WHC All Systems"; Query =  "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ADSiteName = 'WHC'"}

#Create Defaut Folder 
$CollectionFolder = @{Name = "AD SITES"; ObjectType = 5000; ParentContainerNodeId = 0}
Set-WmiInstance -Namespace "root\sms\site_$($SiteCode.Name)" -Class "SMS_ObjectContainerNode" -Arguments $CollectionFolder

#Create Default limiting collections
$LimitingCollection = "All Systems"

#Create Collection
try{
New-CMDeviceCollection -Name $Collection1.Name -Comment "Arizona - BAT - Bank of America Tower" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection1.Name -QueryExpression $Collection1.Query -RuleName $Collection1.Name
Write-host *** Collection $Collection1.Name created ***

New-CMDeviceCollection -Name $Collection2.Name -Comment "Central-California - BMH - Bakersfield Memorial Hospital" -LimitingCollectionName $Collection1.Name -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection2.Name -QueryExpression $Collection2.Query -RuleName $Collection2.Name
Write-host *** Collection $Collection2.Name created ***

New-CMDeviceCollection -Name $Collection3.Name -Comment "Arizona - BNI - Barrow Neurologic Institute" -LimitingCollectionName $Collection1.Name -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection3.Name -QueryExpression $Collection3.Query -RuleName $Collection3.Name
Write-host *** Collection $Collection3.Name created ***

New-CMDeviceCollection -Name $Collection4.Name -Comment "Southern-California - CHC - California Hospital Medical Center" -LimitingCollectionName $Collection1.Name -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection4.Name -QueryExpression $Collection4.Query -RuleName $Collection4.Name
Write-host *** Collection $Collection4.Name created ***

New-CMDeviceCollection -Name $Collection5.Name -Comment "Bay-Area - COR - San Francisco Corporate Office" -LimitingCollectionName $Collection1.Name -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection5.Name -QueryExpression $Collection5.Query -RuleName $Collection5.Name
Write-host *** Collection $Collection5.Name created ***

New-CMDeviceCollection -Name $Collection6.Name -Comment "Arizona - CRH - Chandler Regional Medical Center" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection6.Name -QueryExpression $Collection6.Query -RuleName $Collection6.Name
Write-host *** Collection $Collection6.Name created ***

New-CMDeviceCollection -Name $Collection7.Name -Comment "Southern-California - CSB - Community Hospital of San Bernardino" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection7.Name -QueryExpression $Collection7.Query -RuleName $Collection7.Name
Write-host *** Collection $Collection7.Name created ***

Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection8.Name -QueryExpression $Collection8.Query -RuleName $Collection8.Name
Write-host *** Collection $Collection8.Name created ***

New-CMDeviceCollection -Name $Collection9.Name -Comment "Bay-Area - DMF - Dominican Medical Foundation" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection9.Name -QueryExpression $Collection9.Query -RuleName $Collection9.Name
Write-host *** Collection $Collection9.Name created ***

New-CMDeviceCollection -Name $Collection10.Name -Comment "Bay-Area - DSC - Dominican Hospital" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection10.Name -QueryExpression $Collection10.Query -RuleName $Collection10.Name
Write-host *** Collection $Collection10.Name created ***

New-CMDeviceCollection -Name $Collection11.Name -Comment "Arizona - EDC - Enterprise Datacenter & VPN Client Subnet" -LimitingCollectionName $Collection10.Name -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection11.Name -QueryExpression $Collection11.Query -RuleName $Collection11.Name
Write-host *** Collection $Collection11.Name created ***

New-CMDeviceCollection -Name $Collection12.Name -Comment "Central-Coast - FHM - French Hospital Medical Center" -LimitingCollectionName $Collection10.Name -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection12.Name -QueryExpression $Collection12.Query -RuleName $Collection12.Name
Write-host *** Collection $Collection12.Name created ***

New-CMDeviceCollection -Name $Collection13.Name -Comment "Southern-California - GMH - Glendale Memorial Hospital" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection13.Name -QueryExpression $Collection13.Query -RuleName $Collection13.Name
Write-host *** Collection $Collection13.Name created ***

New-CMDeviceCollection -Name $Collection14.Name -Comment "Southern-California - IHO - Inland Healthcare Organization" -LimitingCollectionName $Collection13.Name -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection14.Name -QueryExpression $Collection14.Query -RuleName $Collection14.Name
Write-host *** Collection $Collection14.Name created ***

New-CMDeviceCollection -Name $Collection15.Name -Comment "Missouri - LS_CHWCA - Cerner Corporation" -LimitingCollectionName $Collection13.Name -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection15.Name -QueryExpression $Collection15.Query -RuleName $Collection15.Name
Write-host *** Collection $Collection15.Name created ***

New-CMDeviceCollection -Name $Collection16.Name -Comment "Nevada - LVS - Las Vegas Datacenter - VPN Client Subnet" -LimitingCollectionName $Collection13.Name -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection16.Name -QueryExpression $Collection16.Query -RuleName $Collection16.Name
Write-host *** Collection $Collection16.Name created ***

New-CMDeviceCollection -Name $Collection17.Name -Comment "Central-California - MCC - Mercy Cancer Center" -LimitingCollectionName $Collection13.Name -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection17.Name -QueryExpression $Collection17.Query -RuleName $Collection17.Name
Write-host *** Collection $Collection17.Name created ***

New-CMDeviceCollection -Name $Collection18.Name -Comment "Central-California - MCM - Mercy Medical Center - Merced" -LimitingCollectionName $Collection10.Name -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection18.Name -QueryExpression $Collection18.Query -RuleName $Collection18.Name
Write-host *** Collection $Collection18.Name created ***

New-CMDeviceCollection -Name $Collection19.Name -Comment "Greater-Sacramento - MET - Methodist Hospital of Sacramento" -LimitingCollectionName $Collection10.Name -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection19.Name -QueryExpression $Collection19.Query -RuleName $Collection19.Name
Write-host *** Collection $Collection19.Name created ***

New-CMDeviceCollection -Name $Collection20.Name -Comment "Arizona - MGC - Mercy Gilbert Medical Center" -LimitingCollectionName $Collection10.Name -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection20.Name -QueryExpression $Collection20.Query -RuleName $Collection20.Name
Write-host *** Collection $Collection20.Name created ***

New-CMDeviceCollection -Name $Collection21.Name -Comment "Greater-Sacramento - MGH - Mercy General Hospital" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection21.Name -QueryExpression $Collection21.Query -RuleName $Collection21.Name
Write-host *** Collection $Collection21.Name created ***

New-CMDeviceCollection -Name $Collection22.Name -Comment "Central-California - MHB - Mercy Hospital Bakersfield" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection22.Name -QueryExpression $Collection22.Query -RuleName $Collection22.Name
Write-host *** Collection $Collection22.Name created ***

New-CMDeviceCollection -Name $Collection23.Name -Comment "Greater-Sacramento - MHF - Mercy Hospital of Folsom" -LimitingCollectionName $Collection10.Name -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection23.Name -QueryExpression $Collection23.Query -RuleName $Collection23.Name
Write-host *** Collection $Collection23.Name created ***

New-CMDeviceCollection -Name $Collection24.Name -Comment "Greater-Sacramento - MIC - Mercy Imaging Center" -LimitingCollectionName $Collection10.Name -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection24.Name -QueryExpression $Collection24.Query -RuleName $Collection24.Name
Write-host *** Collection $Collection24.Name created ***

New-CMDeviceCollection -Name $Collection25.Name -Comment "Central-Coast - MMC - Marian Regional Medical Center" -LimitingCollectionName $Collection10.Name -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection25.Name -QueryExpression $Collection25.Query -RuleName $Collection25.Name
Write-host *** Collection $Collection25.Name created ***

New-CMDeviceCollection -Name $Collection26.Name -Comment "North-State - MMR - Mercy Medical Center - Redding" -LimitingCollectionName $Collection13.Name -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection26.Name -QueryExpression $Collection26.Query -RuleName $Collection26.Name
Write-host *** Collection $Collection26.Name created ***

New-CMDeviceCollection -Name $Collection27.Name -Comment "North-State - MMS - Mercy Medical Center - Mt. Shasta" -LimitingCollectionName $Collection13.Name -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection27.Name -QueryExpression $Collection27.Query -RuleName $Collection27.Name
Write-host *** Collection $Collection27.Name created ***

New-CMDeviceCollection -Name $Collection28.Name -Comment "Central-California - MSH - Mercy Southwest Hospital" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection28.Name -QueryExpression $Collection28.Query -RuleName $Collection28.Name
Write-host *** Collection $Collection28.Name created ***

New-CMDeviceCollection -Name $Collection29.Name -Comment "Greater-Sacramento - MSJ - Mercy San Juan Medical Center" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection29.Name -QueryExpression $Collection29.Query -RuleName $Collection29.Name
Write-host *** Collection $Collection29.Name created ***

New-CMDeviceCollection -Name $Collection30.Name -Comment "Central-California - MTC - Mark Twain Medical Center" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection30.Name -QueryExpression $Collection30.Query -RuleName $Collection30.Name
Write-host *** Collection $Collection30.Name created ***

New-CMDeviceCollection -Name $Collection31.Name -Comment "Southern-California - NHC - Northridge Hospital Medical Center" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection31.Name -QueryExpression $Collection31.Query -RuleName $Collection31.Name
Write-host *** Collection $Collection31.Name created ***

New-CMDeviceCollection -Name $Collection32.Name -Comment "Southern-California - PAS - Pasadena System Office" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection32.Name -QueryExpression $Collection32.Query -RuleName $Collection32.Name
Write-host *** Collection $Collection32.Name created ***

New-CMDeviceCollection -Name $Collection33.Name -Comment "Arizona - 35.25.169.234 - Phoenix Corporate Office 2" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection33.Name -QueryExpression $Collection33.Query -RuleName $Collection33.Name
Write-host *** Collection $Collection33.Name created ***

New-CMDeviceCollection -Name $Collection34.Name -Comment "Greater-Sacramento - SAC - Rancho Cordova Datacenter" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection34.Name -QueryExpression $Collection34.Query -RuleName $Collection34.Name
Write-host *** Collection $Collection34.Name created ***

New-CMDeviceCollection -Name $Collection35.Name -Comment "Greater-Sacramento - SAC2 - Rancho Cordova System Office" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection35.Name -QueryExpression $Collection35.Query -RuleName $Collection35.Name
Write-host *** Collection $Collection35.Name created ***

New-CMDeviceCollection -Name $Collection36.Name -Comment "Greater-Sacramento - SAC3 - Rancho Cordova System Office 2 (Gold Circle Drive)" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection36.Name -QueryExpression $Collection36.Query -RuleName $Collection36.Name
Write-host *** Collection $Collection36.Name created ***

New-CMDeviceCollection -Name $Collection37.Name -Comment "Southern-California - SBM - St. Bernadine Medical Center" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection37.Name -QueryExpression $Collection37.Query -RuleName $Collection37.Name
Write-host *** Collection $Collection37.Name created ***

New-CMDeviceCollection -Name $Collection38.Name -Comment "North-State - SEH - St. Elizabeth's Community Hospital" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection38.Name -QueryExpression $Collection38.Query -RuleName $Collection38.Name
Write-host *** Collection $Collection38.Name created ***

New-CMDeviceCollection -Name $Collection39.Name -Comment "Bay-Area - SEQ - Sequoia Hospital" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection39.Name -QueryExpression $Collection39.Query -RuleName $Collection39.Name
Write-host *** Collection $Collection39.Name created ***

New-CMDeviceCollection -Name $Collection40.Name -Comment "Bay-Area - SFH - St. Francis Memorial Hospital" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection40.Name -QueryExpression $Collection40.Query -RuleName $Collection40.Name
Write-host *** Collection $Collection40.Name created ***

New-CMDeviceCollection -Name $Collection41.Name -Comment "Central-California - SJB - St. Joseph's Behaviorial Health Center - Stockton" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection41.Name -QueryExpression $Collection41.Query -RuleName $Collection41.Name
Write-host *** Collection $Collection41.Name created ***

New-CMDeviceCollection -Name $Collection42.Name -Comment "Arizona - SJH - St. Joseph's Hospital and Medical Center" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection42.Name -QueryExpression $Collection42.Query -RuleName $Collection42.Name
Write-host *** Collection $Collection42.Name created ***

New-CMDeviceCollection -Name $Collection43.Name -Comment "Central-California - SJM - St. Joseph's Medical Center - Stockton" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection43.Name -QueryExpression $Collection43.Query -RuleName $Collection43.Name
Write-host *** Collection $Collection43.Name created ***

New-CMDeviceCollection -Name $Collection44.Name -Comment "Central-Coast - SJP - St. John's Pleasant Valley Hospital" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection44.Name -QueryExpression $Collection44.Query -RuleName $Collection44.Name
Write-host *** Collection $Collection44.Name created ***

New-CMDeviceCollection -Name $Collection45.Name -Comment "Central-Coast - SJR - St. John's Regional Medical Center" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection45.Name -QueryExpression $Collection45.Query -RuleName $Collection45.Name
Write-host *** Collection $Collection45.Name created ***

New-CMDeviceCollection -Name $Collection46.Name -Comment "Southern-California - SML -  St. Mary's Medical Center - Long Beach" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection46.Name -QueryExpression $Collection46.Query -RuleName $Collection46.Name
Write-host *** Collection $Collection46.Name created ***

New-CMDeviceCollection -Name $Collection47.Name -Comment "All systems with SCCM client version 1511 installed" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection47.Name -QueryExpression $Collection47.Query -RuleName $Collection47.Name
Write-host *** Collection $Collection47.Name created ***

New-CMDeviceCollection -Name $Collection48.Name -Comment "Nevada - SMR - St. Mary's Reno (Clinics)" -LimitingCollectionName $Collection9.Name -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection48.Name -QueryExpression $Collection48.Query -RuleName $Collection48.Name
Write-host *** Collection $Collection48.Name created ***

New-CMDeviceCollection -Name $Collection49.Name -Comment "Bay-Area - SFH - St. Mary's Medical Center" -LimitingCollectionName $Collection9.Name -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection49.Name -QueryExpression $Collection49.Query -RuleName $Collection49.Name
Write-host *** Collection $Collection49.Name created ***

New-CMDeviceCollection -Name $Collection50.Name -Comment "Greater-Sacramento - SNM - Sierra Nevada Memorial Hospital" -LimitingCollectionName $Collection9.Name -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection50.Name -QueryExpression $Collection50.Query -RuleName $Collection50.Name
Write-host *** Collection $Collection50.Name created ***

New-CMDeviceCollection -Name $Collection51.Name -Comment "Nevada - SRD - St. Rose Dominican Hospital - Rose De Lima" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection51.Name -QueryExpression $Collection51.Query -RuleName $Collection51.Name
Write-host *** Collection $Collection51.Name created ***

New-CMDeviceCollection -Name $Collection52.Name -Comment "Nevada - SRM - St. Rose Dominican Hospital - San Martin" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection52.Name -QueryExpression $Collection52.Query -RuleName $Collection52.Name
Write-host *** Collection $Collection52.Name created ***

New-CMDeviceCollection -Name $Collection53.Name -Comment "Nevada - SRS - St. Rose Dominican Hospital - Sienna" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection53.Name -QueryExpression $Collection53.Query -RuleName $Collection53.Name
Write-host *** Collection $Collection53.Name created ***

New-CMDeviceCollection -Name $Collection54.Name -Comment "Arizona - UAC - University of Arizona Cancer Center" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection54.Name -QueryExpression $Collection54.Query -RuleName $Collection54.Name
Write-host *** Collection $Collection54.Name created ***

New-CMDeviceCollection -Name $Collection55.Name -Comment "Greater-Sacramento - WHC - Woodland Healthcare" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection55.Name -QueryExpression $Collection55.Query -RuleName $Collection55.Name
Write-host *** Collection $Collection55.Name created ***


#Move the collection to the right folder
$FolderPath = $SiteCode.Name + ":\DeviceCollection\Informational\AD SITES"

Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection1.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection1.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection2.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection3.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection4.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection5.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection6.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection7.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection8.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection9.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection10.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection11.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection12.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection13.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection14.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection15.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection16.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection17.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection18.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection19.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection20.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection21.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection22.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection23.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection24.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection25.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection26.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection27.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection28.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection29.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection30.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection31.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection32.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection33.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection34.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection35.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection36.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection37.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection38.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection39.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection40.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection41.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection42.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection43.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection44.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection45.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection46.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection47.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection48.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection49.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection50.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection51.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection52.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection53.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection54.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection55.Name)

}
catch{
$Error1 = 1
}
Finally{
    If ($Error1 -eq 1){
        Write-host "-----------------"
        Write-host -ForegroundColor Red "Script has already been run or a collection name already exist. Delete All AD Site collection before re-executing the script !"
        Write-host "-----------------"
        Pause
    }
    Else{
        Write-host "-----------------"
        Write-Host -ForegroundColor Green "Script execution completed without errors. AD Site Based Collections created sucessfully"
        Write-host "-----------------"
        Pause
        }
        }