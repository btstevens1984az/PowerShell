# Purpose: Operational Collection 2.9 — Configuration Manager collections and deployments.
#############################################################################
#
# Version : 2.8
# 2014/08/14 - Added Collection 34,35,36
# 2014/09/23 - Changed collection 4 to CU3 instead of CU2
# 2015/01/30 - Improve Android collection
# 2015/02/03 - Changed collection 4 to CU4 instead of CU3
# 2015/05/06 - Changed collection 4 to CU5 instead of CU4
# 2015/05/06 - Changed collection 4 to SP1 instead of CU5
#            - Add collections 37 to 42
# 2015/08/04 - Add collection 43,44
#            - Changed collection 4 to SP1 CU1 instead of SP1
# 2015/08/06 - Change collection 22 query
# 2015/08/12 - Added Windows 10 - Collection 45
# 2015/11/10 - Changed collection 4 to SP1 CU2 instead of CU1, Add collection 46
# 2015/12/04 - Changed collection 4 to SCCM 1511 instead of CU2, Add collection 47
# 2016/02/16 - Add collection 48 and 49. Complete Revamp of Collections naming. Comment added on all collections
# 2016/03/03 - Add collection 51
# 2016/03/14 - Add collection 52
# 2016/03/15 - Added Error handling and better output
# 2016/08/08 - Add collection 53-56. Modification to collection 4,31,32,33
# 2016/09/14 - Add collection 57
# 2016/10/03 - Add collection 58 to 63
# 2016/10/14 - Add collection 64 to 67
# 2016/10/28 - Bug fixes and updated collection 50
# 2016/11/18 - Add collection 68
# 2017/02/03 - Corrected collection 39 and 68
# 2017/03/27 - Add collection 69,70,71
# 2017/08/25 - Add collection 72
# 2017/11/21 - Add collection 73
# 
#
# Purpose : This script create a set of SCCM collections and move it in an "Operational" folder
#
#############################################################################

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
$Schedule = New-CMSchedule –RecurInterval Days –RecurCount 7

#List of Collections Query
$Collection1 = @{Name = "Clients | All"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.Client = 1"}
$Collection2 = @{Name = "System Health | Clients Inactive"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_CH_ClientSummary on SMS_G_System_CH_ClientSummary.ResourceId = SMS_R_System.ResourceId where SMS_G_System_CH_ClientSummary.ClientActiveStatus = 0 and SMS_R_System.Client = 1 and SMS_R_System.Obsolete = 0"}
$Collection3 = @{Name = "System Health | Clients Active"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_CH_ClientSummary on SMS_G_System_CH_ClientSummary.ResourceId = SMS_R_System.ResourceId where SMS_G_System_CH_ClientSummary.ClientActiveStatus = 1 and SMS_R_System.Client = 1 and SMS_R_System.Obsolete = 0"}
$Collection4 = @{Name = "Clients version | Not Latest (1710)"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion != '5.00.8577.1003'"}
$Collection5 = @{Name = "Hardware Inventory | Clients Not Reporting since 14 Days"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where ResourceId in (select SMS_R_System.ResourceID from SMS_R_System inner join SMS_G_System_WORKSTATION_STATUS on SMS_G_System_WORKSTATION_STATUS.ResourceID = SMS_R_System.ResourceId where DATEDIFF(dd,SMS_G_System_WORKSTATION_STATUS.LastHardwareScan,GetDate()) > 14)"}
$Collection6 = @{Name = "Clients | No"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.Client = 0 OR SMS_R_System.Client is NULL"}
$Collection7 = @{Name = "System Health | Obsolete"; Query = "select *  from  SMS_R_System where SMS_R_System.Obsolete = 1"}
$Collection8 = @{Name = "Workstations | Active"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_CH_ClientSummary on SMS_G_System_CH_ClientSummary.ResourceId = SMS_R_System.ResourceId where (SMS_R_System.OperatingSystemNameandVersion like 'Microsoft Windows NT%Workstation%' or SMS_R_System.OperatingSystemNameandVersion = 'Windows 7 Entreprise 6.1') and SMS_G_System_CH_ClientSummary.ClientActiveStatus = 1 and SMS_R_System.Client = 1 and SMS_R_System.Obsolete = 0"}
$Collection9 = @{Name = "Laptops | All"; Query = "select SMS_R_System.ResourceId, SMS_R_System.ResourceType, SMS_R_System.Name, SMS_R_System.SMSUniqueIdentifier, SMS_R_System.ResourceDomainORWorkgroup, SMS_R_System.Client from  SMS_R_System inner join SMS_G_System_SYSTEM_ENCLOSURE on SMS_G_System_SYSTEM_ENCLOSURE.ResourceID = SMS_R_System.ResourceId where SMS_G_System_SYSTEM_ENCLOSURE.ChassisTypes in ('8', '9', '10', '11', '12', '14', '18', '21')"}
$Collection10 = @{Name = "Servers | All"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where OperatingSystemNameandVersion like '%Server%'"}
$Collection11 = @{Name = "Servers | Physical"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ResourceId not in (select SMS_R_SYSTEM.ResourceID from SMS_R_System inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_R_System.IsVirtualMachine = 'True') and SMS_R_System.OperatingSystemNameandVersion like 'Microsoft Windows NT%Server%'"}
$Collection12 = @{Name = "Servers | Virtual"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.IsVirtualMachine = 'True' and SMS_R_System.OperatingSystemNameandVersion like 'Microsoft Windows NT%Server%'"}
$Collection13 = @{Name = "Workstations | All"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where OperatingSystemNameandVersion like '%Workstation%'"}
$Collection14 = @{Name = "Workstations | Windows 7"; Query = "select SMS_R_System.ResourceID,SMS_R_System.ResourceType,SMS_R_System.Name,SMS_R_System.SMSUniqueIdentifier,SMS_R_System.ResourceDomainORWorkgroup,SMS_R_System.Client from SMS_R_System where OperatingSystemNameandVersion like '%Workstation 6.1%'"}
$Collection15 = @{Name = "Workstations | Windows 8"; Query = "select SMS_R_System.ResourceID,SMS_R_System.ResourceType,SMS_R_System.Name,SMS_R_System.SMSUniqueIdentifier,SMS_R_System.ResourceDomainORWorkgroup,SMS_R_System.Client from SMS_R_System where OperatingSystemNameandVersion like '%Workstation 6.2%'"}
$Collection16 = @{Name = "Workstations | Windows 8.1"; Query = "select SMS_R_System.ResourceID,SMS_R_System.ResourceType,SMS_R_System.Name,SMS_R_System.SMSUniqueIdentifier,SMS_R_System.ResourceDomainORWorkgroup,SMS_R_System.Client from SMS_R_System where OperatingSystemNameandVersion like '%Workstation 6.3%'"}
$Collection17 = @{Name = "Workstations | Windows XP"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System   where OperatingSystemNameandVersion like '%Workstation 5.1%' or OperatingSystemNameandVersion like '%Workstation 5.2%'"}
$Collection18 = @{Name = "Servers | Windows 2008 and 2008 R2"; Query = "select SMS_R_System.ResourceID,SMS_R_System.ResourceType,SMS_R_System.Name,SMS_R_System.SMSUniqueIdentifier,SMS_R_System.ResourceDomainORWorkgroup,SMS_R_System.Client from SMS_R_System where OperatingSystemNameandVersion like '%Server 6.0%' or OperatingSystemNameandVersion like '%Server 6.1%'"}
$Collection19 = @{Name = "Servers | Windows 2012 and 2012 R2"; Query = "select SMS_R_System.ResourceID,SMS_R_System.ResourceType,SMS_R_System.Name,SMS_R_System.SMSUniqueIdentifier,SMS_R_System.ResourceDomainORWorkgroup,SMS_R_System.Client from SMS_R_System where OperatingSystemNameandVersion like '%Server 6.2%' or OperatingSystemNameandVersion like '%Server 6.3%'"}
$Collection20 = @{Name = "Servers | Windows 2003 and 2003 R2"; Query = "select SMS_R_System.ResourceID,SMS_R_System.ResourceType,SMS_R_System.Name,SMS_R_System.SMSUniqueIdentifier,SMS_R_System.ResourceDomainORWorkgroup,SMS_R_System.Client from SMS_R_System where OperatingSystemNameandVersion like '%Server 5.2%'"}
$Collection21 = @{Name = "Systems | Created Since 24h"; Query = "select SMS_R_System.Name, SMS_R_System.CreationDate FROM SMS_R_System WHERE DateDiff(dd,SMS_R_System.CreationDate, GetDate()) <= 1"}
$Collection22 = @{Name = "SCCM | Console"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_ADD_REMOVE_PROGRAMS on SMS_G_System_ADD_REMOVE_PROGRAMS.ResourceID = SMS_R_System.ResourceId where SMS_G_System_ADD_REMOVE_PROGRAMS.DisplayName like '%Configuration Manager Console%'"}
$Collection23 = @{Name = "SCCM | Site System"; Query = "select SMS_R_System.ResourceId, SMS_R_System.ResourceType, SMS_R_System.Name, SMS_R_System.SMSUniqueIdentifier, SMS_R_System.ResourceDomainORWorkgroup, SMS_R_System.Client from  SMS_R_System where SMS_R_System.SystemRoles = 'SMS Site System'"}
$Collection24 = @{Name = "SCCM | Site Servers"; Query = "select SMS_R_System.ResourceId, SMS_R_System.ResourceType, SMS_R_System.Name, SMS_R_System.SMSUniqueIdentifier, SMS_R_System.ResourceDomainORWorkgroup, SMS_R_System.Client from  SMS_R_System where SMS_R_System.SystemRoles = 'SMS Site Server'"}
$Collection25 = @{Name = "SCCM | Distribution Points"; Query = "select SMS_R_System.ResourceId, SMS_R_System.ResourceType, SMS_R_System.Name, SMS_R_System.SMSUniqueIdentifier, SMS_R_System.ResourceDomainORWorkgroup, SMS_R_System.Client from  SMS_R_System where SMS_R_System.SystemRoles = 'SMS Distribution Point'"}
$Collection26 = @{Name = "Windows Update Agent | Outdated Version Win7 RTM and Lower"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_WINDOWSUPDATEAGENTVERSION on SMS_G_System_WINDOWSUPDATEAGENTVERSION.ResourceID = SMS_R_System.ResourceId inner join SMS_G_System_OPERATING_SYSTEM on SMS_G_System_OPERATING_SYSTEM.ResourceID = SMS_R_System.ResourceId where SMS_G_System_WINDOWSUPDATEAGENTVERSION.Version < '7.6.7600.256' and SMS_G_System_OPERATING_SYSTEM.Version <= '6.1.7600'"}
$Collection27 = @{Name = "Windows Update Agent | Outdated Version Win7 SP1 and Higher"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_WINDOWSUPDATEAGENTVERSION on SMS_G_System_WINDOWSUPDATEAGENTVERSION.ResourceID = SMS_R_System.ResourceId inner join SMS_G_System_OPERATING_SYSTEM on SMS_G_System_OPERATING_SYSTEM.ResourceID = SMS_R_System.ResourceId where SMS_G_System_WINDOWSUPDATEAGENTVERSION.Version < '7.6.7600.320' and SMS_G_System_OPERATING_SYSTEM.Version >= '6.1.7601'"}
$Collection28 = @{Name = "Mobile Devices | Android"; Query = "SELECT SMS_R_System.ResourceId, SMS_R_System.ResourceType, SMS_R_System.Name, SMS_R_System.SMSUniqueIdentifier, SMS_R_System.ResourceDomainORWorkgroup, SMS_R_System.Client FROM SMS_R_System INNER JOIN SMS_G_System_DEVICE_OSINFORMATION ON SMS_G_System_DEVICE_OSINFORMATION.ResourceID = SMS_R_System.ResourceId WHERE SMS_G_System_DEVICE_OSINFORMATION.Platform like 'Android%'"}
$Collection29 = @{Name = "Mobile Devices | Iphone"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_DEVICE_COMPUTERSYSTEM on SMS_G_System_DEVICE_COMPUTERSYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_G_System_DEVICE_COMPUTERSYSTEM.DeviceModel like '%Iphone%'"}
$Collection30 = @{Name = "Mobile Devices | Ipad"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_DEVICE_COMPUTERSYSTEM on SMS_G_System_DEVICE_COMPUTERSYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_G_System_DEVICE_COMPUTERSYSTEM.DeviceModel like '%Ipad%'"}
$Collection31 = @{Name = "Mobile Devices | Windows Phone 8"; Query = "select SMS_R_System.ResourceId, SMS_R_System.ResourceType, SMS_R_System.Name, SMS_R_System.SMSUniqueIdentifier, SMS_R_System.ResourceDomainORWorkgroup, SMS_R_System.Client from SMS_R_System inner join SMS_G_System_DEVICE_OSINFORMATION on SMS_G_System_DEVICE_OSINFORMATION.ResourceID = SMS_R_System.ResourceId where SMS_G_System_DEVICE_OSINFORMATION.Platform = 'Windows Phone' and SMS_G_System_DEVICE_OSINFORMATION.Version like '8.0%'"}
$Collection32 = @{Name = "Mobile Devices | Windows Phone 8.1"; Query = "select SMS_R_System.ResourceId, SMS_R_System.ResourceType, SMS_R_System.Name, SMS_R_System.SMSUniqueIdentifier, SMS_R_System.ResourceDomainORWorkgroup, SMS_R_System.Client from SMS_R_System inner join SMS_G_System_DEVICE_OSINFORMATION on SMS_G_System_DEVICE_OSINFORMATION.ResourceID = SMS_R_System.ResourceId where SMS_G_System_DEVICE_OSINFORMATION.Platform = 'Windows Phone' and SMS_G_System_DEVICE_OSINFORMATION.Version like '8.1%'"}
$Collection33 = @{Name = "Mobile Devices | Microsoft Surface"; Query = "select SMS_R_System.ResourceId, SMS_R_System.ResourceType, SMS_R_System.Name, SMS_R_System.SMSUniqueIdentifier, SMS_R_System.ResourceDomainORWorkgroup, SMS_R_System.Client from SMS_R_System inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_G_System_COMPUTER_SYSTEM.Model like '%Surface%'"}
$Collection34 = @{Name = "System Health | Disabled"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.UserAccountControl ='4098'"}
$Collection35 = @{Name = "Systems | x86"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceID = SMS_R_System.ResourceId where SMS_G_System_COMPUTER_SYSTEM.SystemType = 'X86-based PC'"}
$Collection36 = @{Name = "Systems | x64"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceID = SMS_R_System.ResourceId where SMS_G_System_COMPUTER_SYSTEM.SystemType = 'X64-based PC'"}
$Collection37 = @{Name = "Clients Version | R2 CU1"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion = '5.00.7958.1203'"}
$Collection38 = @{Name = "Clients Version | R2 CU2"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion = '5.00.7958.1303'"}
$Collection39 = @{Name = "Clients Version | R2 CU3"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion like '5.00.7958.14%'"}
$Collection40 = @{Name = "Clients Version | R2 CU4"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion = '5.00.7958.1501'"}
$Collection41 = @{Name = "Clients Version | R2 CU5"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion = '5.00.7958.1604'"}
$Collection42 = @{Name = "Clients Version | R2 CU0"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion = '5.00.7958.1000'"}
$Collection43 = @{Name = "Clients Version | R2 SP1"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion = '5.00.8239.1000'"}
$Collection44 = @{Name = "Clients Version | R2 SP1 CU1"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion = '5.00.8239.1203'"}
$Collection45 = @{Name = "Workstations | Windows 10"; Query = "select SMS_R_System.ResourceID,SMS_R_System.ResourceType,SMS_R_System.Name,SMS_R_System.SMSUniqueIdentifier,SMS_R_System.ResourceDomainORWorkgroup,SMS_R_System.Client from SMS_R_System where OperatingSystemNameandVersion like '%Workstation 10.0%'"}
$Collection46 = @{Name = "Clients Version | R2 SP1 CU2"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion = '5.00.8239.1301'"}
$Collection47 = @{Name = "Clients Version | 1511"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion = '5.00.8325.1000'"}
$Collection48 = @{Name = "Laptops | Dell"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_G_System_COMPUTER_SYSTEM.Manufacturer like '%Dell%'"}
$Collection49 = @{Name = "Laptops | Lenovo"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_G_System_COMPUTER_SYSTEM.Manufacturer like '%Lenovo%'"}
$Collection50 = @{Name = "Laptops | HP"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_G_System_COMPUTER_SYSTEM.Manufacturer like '%HP%' or SMS_G_System_COMPUTER_SYSTEM.Manufacturer like '%Hewlett-Packard%'"}
$Collection51 = @{Name = "Clients Version | R2 SP1 CU3"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion = '5.00.8239.1403'"}
$Collection52 = @{Name = "Clients Version | 1602"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion = '5.00.8355.1000'"}
$Collection53 = @{Name = "Clients Version | 1606"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion like '5.00.8412.100%'"}
$Collection54 = @{Name = "Mobile Devices | Microsoft Surface 3"; Query = "select SMS_R_System.ResourceId, SMS_R_System.ResourceType, SMS_R_System.Name, SMS_R_System.SMSUniqueIdentifier, SMS_R_System.ResourceDomainORWorkgroup, SMS_R_System.Client from SMS_R_System inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_G_System_COMPUTER_SYSTEM.Model = 'Surface Pro 3' OR SMS_G_System_COMPUTER_SYSTEM.Model = 'Surface 3'"}
$Collection55 = @{Name = "Mobile Devices | Microsoft Surface 4"; Query = "select SMS_R_System.ResourceId, SMS_R_System.ResourceType, SMS_R_System.Name, SMS_R_System.SMSUniqueIdentifier, SMS_R_System.ResourceDomainORWorkgroup, SMS_R_System.Client from SMS_R_System inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_G_System_COMPUTER_SYSTEM.Model = 'Surface Pro 4'"}
$Collection56 = @{Name = "Mobile Devices | Windows Phone 10"; Query = "select SMS_R_System.ResourceId, SMS_R_System.ResourceType, SMS_R_System.Name, SMS_R_System.SMSUniqueIdentifier, SMS_R_System.ResourceDomainORWorkgroup, SMS_R_System.Client from SMS_R_System inner join SMS_G_System_DEVICE_OSINFORMATION on SMS_G_System_DEVICE_OSINFORMATION.ResourceID = SMS_R_System.ResourceId where SMS_G_System_DEVICE_OSINFORMATION.Platform = 'Windows Phone' and SMS_G_System_DEVICE_OSINFORMATION.Version like '10%'"}
$Collection57 = @{Name = "Mobile Devices | All"; Query = "select * from SMS_R_System where SMS_R_System.ClientType = 3"}
$Collection58 = @{Name = "Workstations | Windows 10 v1507"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.Build like '10.0.10240%'"}
$Collection59 = @{Name = "Workstations | Windows 10 v1511"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.Build like '10.0.10586%'"}
$Collection60 = @{Name = "Workstations | Windows 10 v1607"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.Build like '10.0.14393%'"}
$Collection61 = @{Name = "Workstations | Windows 10 Current Branch (CB)"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.OperatingSystemNameandVersion like '%Workstation 10.0%' and SMS_R_System.OSBranch = '0'"}
$Collection62 = @{Name = "Workstations | Windows 10 Current Branch for Business (CBB)"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.OperatingSystemNameandVersion like '%Workstation 10.0%' and SMS_R_System.OSBranch = '1'"}
$Collection63 = @{Name = "Workstations | Windows 10 Long Term Servicing Branch (LTSB)"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.OperatingSystemNameandVersion like '%Workstation 10.0%' and SMS_R_System.OSBranch = '2'"}
$Collection64 = @{Name = "Workstations | Windows 10 Support State - Current"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System  LEFT OUTER JOIN SMS_WindowsServicingStates ON SMS_WindowsServicingStates.Build = SMS_R_System.build01 AND SMS_WindowsServicingStates.branch = SMS_R_System.osbranch01 where SMS_WindowsServicingStates.State = '2'"}
$Collection65 = @{Name = "Workstations | Windows 10 Support State - Expired Soon"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System  LEFT OUTER JOIN SMS_WindowsServicingStates ON SMS_WindowsServicingStates.Build = SMS_R_System.build01 AND SMS_WindowsServicingStates.branch = SMS_R_System.osbranch01 where SMS_WindowsServicingStates.State = '3'"}
$Collection66 = @{Name = "Workstations | Windows 10 Support State - Expired"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System  LEFT OUTER JOIN SMS_WindowsServicingStates ON SMS_WindowsServicingStates.Build = SMS_R_System.build01 AND SMS_WindowsServicingStates.branch = SMS_R_System.osbranch01 where SMS_WindowsServicingStates.State = '4'"}
$Collection67 = @{Name = "Servers | Windows 2016"; Query = "select SMS_R_System.ResourceID,SMS_R_System.ResourceType,SMS_R_System.Name,SMS_R_System.SMSUniqueIdentifier,SMS_R_System.ResourceDomainORWorkgroup,SMS_R_System.Client from SMS_R_System where OperatingSystemNameandVersion like '%Server 10%'"}
$Collection68 = @{Name = "Clients Version | 1610"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion like '5.00.8458.100%'"}
$Collection69 = @{Name = "Clients Version | 1702"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion like '5.00.8498.100%'"}
$Collection70 = @{Name = "Others | Linux Devices"; Query = "select *  from  SMS_R_System where SMS_R_System.ClientEdition = 13"}
$Collection71 = @{Name = "Others | MAC OSX Devices"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System WHERE OperatingSystemNameandVersion LIKE 'Apple Mac OS X%'"}
$Collection72 = @{Name = "Clients Version | 1706"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion like '5.00.8540.100%'"}
$Collection73 = @{Name = "Clients Version | 1710"; Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion like '5.00.8577.100%'"}

#Create Defaut Folder 
$CollectionFolder = @{Name = "Operational"; ObjectType = 5000; ParentContainerNodeId = 0}
Set-WmiInstance -Namespace "root\sms\site_$($SiteCode.Name)" -Class "SMS_ObjectContainerNode" -Arguments $CollectionFolder

#Create Default limiting collections
$LimitingCollection = "All Systems"

#Create Collection
try{
New-CMDeviceCollection -Name $Collection1.Name -Comment "All devices detected by SCCM" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection1.Name -QueryExpression $Collection1.Query -RuleName $Collection1.Name
Write-host *** Collection $Collection1.Name created ***

New-CMDeviceCollection -Name $Collection2.Name -Comment "All devices with SCCM client state inactive" -LimitingCollectionName $Collection1.Name -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection2.Name -QueryExpression $Collection2.Query -RuleName $Collection2.Name
Write-host *** Collection $Collection2.Name created ***

New-CMDeviceCollection -Name $Collection3.Name -Comment "All devices with SCCM client state active" -LimitingCollectionName $Collection1.Name -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection3.Name -QueryExpression $Collection3.Query -RuleName $Collection3.Name
Write-host *** Collection $Collection3.Name created ***

New-CMDeviceCollection -Name $Collection4.Name -Comment "All devices without SCCM client version 1511" -LimitingCollectionName $Collection1.Name -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection4.Name -QueryExpression $Collection4.Query -RuleName $Collection4.Name
Write-host *** Collection $Collection4.Name created ***

New-CMDeviceCollection -Name $Collection5.Name -Comment "All devices with SCCM client that have not communicated with hardware inventory over 14 days" -LimitingCollectionName $Collection1.Name -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection5.Name -QueryExpression $Collection5.Query -RuleName $Collection5.Name
Write-host *** Collection $Collection5.Name created ***

New-CMDeviceCollection -Name $Collection6.Name -Comment "All devices without SCCM client installed" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection6.Name -QueryExpression $Collection6.Query -RuleName $Collection6.Name
Write-host *** Collection $Collection6.Name created ***

New-CMDeviceCollection -Name $Collection7.Name -Comment "All devices with SCCM client state obsolete" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection7.Name -QueryExpression $Collection7.Query -RuleName $Collection7.Name
Write-host *** Collection $Collection7.Name created ***

New-CMDeviceCollection -Name $Collection8.Name -Comment "All workstations with active state" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection8.Name -QueryExpression $Collection8.Query -RuleName $Collection8.Name
Write-host *** Collection $Collection8.Name created ***

New-CMDeviceCollection -Name $Collection9.Name -Comment "All laptops" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection9.Name -QueryExpression $Collection9.Query -RuleName $Collection9.Name
Write-host *** Collection $Collection9.Name created ***

New-CMDeviceCollection -Name $Collection10.Name -Comment "All servers" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection10.Name -QueryExpression $Collection10.Query -RuleName $Collection10.Name
Write-host *** Collection $Collection10.Name created ***

New-CMDeviceCollection -Name $Collection11.Name -Comment "All physical servers" -LimitingCollectionName $Collection10.Name -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection11.Name -QueryExpression $Collection11.Query -RuleName $Collection11.Name
Write-host *** Collection $Collection11.Name created ***

New-CMDeviceCollection -Name $Collection12.Name -Comment "All virtual servers" -LimitingCollectionName $Collection10.Name -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection12.Name -QueryExpression $Collection12.Query -RuleName $Collection12.Name
Write-host *** Collection $Collection12.Name created ***

New-CMDeviceCollection -Name $Collection13.Name -Comment "All workstations" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection13.Name -QueryExpression $Collection13.Query -RuleName $Collection13.Name
Write-host *** Collection $Collection13.Name created ***

New-CMDeviceCollection -Name $Collection14.Name -Comment "All workstations with Windows 7 operating system" -LimitingCollectionName $Collection13.Name -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection14.Name -QueryExpression $Collection14.Query -RuleName $Collection14.Name
Write-host *** Collection $Collection14.Name created ***

New-CMDeviceCollection -Name $Collection15.Name -Comment "All workstations with Windows 8 operating system" -LimitingCollectionName $Collection13.Name -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection15.Name -QueryExpression $Collection15.Query -RuleName $Collection15.Name
Write-host *** Collection $Collection15.Name created ***

New-CMDeviceCollection -Name $Collection16.Name -Comment "All workstations with Windows 8.1 operating system" -LimitingCollectionName $Collection13.Name -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection16.Name -QueryExpression $Collection16.Query -RuleName $Collection16.Name
Write-host *** Collection $Collection16.Name created ***

New-CMDeviceCollection -Name $Collection17.Name -Comment "All workstations with Windows XP operating system" -LimitingCollectionName $Collection13.Name -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection17.Name -QueryExpression $Collection17.Query -RuleName $Collection17.Name
Write-host *** Collection $Collection17.Name created ***

New-CMDeviceCollection -Name $Collection18.Name -Comment "All servers with Windows 2008 or 2008 R2 operating system" -LimitingCollectionName $Collection10.Name -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection18.Name -QueryExpression $Collection18.Query -RuleName $Collection18.Name
Write-host *** Collection $Collection18.Name created ***

New-CMDeviceCollection -Name $Collection19.Name -Comment "All servers with Windows 2012 or 2012 R2 operating system" -LimitingCollectionName $Collection10.Name -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection19.Name -QueryExpression $Collection19.Query -RuleName $Collection19.Name
Write-host *** Collection $Collection19.Name created ***

New-CMDeviceCollection -Name $Collection20.Name -Comment "All servers with Windows 2003 or 2003 R2 operating system" -LimitingCollectionName $Collection10.Name -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection20.Name -QueryExpression $Collection20.Query -RuleName $Collection20.Name
Write-host *** Collection $Collection20.Name created ***

New-CMDeviceCollection -Name $Collection21.Name -Comment "All systems created in the last 24 hours" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection21.Name -QueryExpression $Collection21.Query -RuleName $Collection21.Name
Write-host *** Collection $Collection21.Name created ***

New-CMDeviceCollection -Name $Collection22.Name -Comment "All systems with SCCM console installed" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection22.Name -QueryExpression $Collection22.Query -RuleName $Collection22.Name
Write-host *** Collection $Collection22.Name created ***

New-CMDeviceCollection -Name $Collection23.Name -Comment "All systems that is SCCM site system" -LimitingCollectionName $Collection10.Name -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection23.Name -QueryExpression $Collection23.Query -RuleName $Collection23.Name
Write-host *** Collection $Collection23.Name created ***

New-CMDeviceCollection -Name $Collection24.Name -Comment "All systems that is SCCM site server" -LimitingCollectionName $Collection10.Name -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection24.Name -QueryExpression $Collection24.Query -RuleName $Collection24.Name
Write-host *** Collection $Collection24.Name created ***

New-CMDeviceCollection -Name $Collection25.Name -Comment "All systems that is SCCM distribution point" -LimitingCollectionName $Collection10.Name -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection25.Name -QueryExpression $Collection25.Query -RuleName $Collection25.Name
Write-host *** Collection $Collection25.Name created ***

New-CMDeviceCollection -Name $Collection26.Name -Comment "All systems with windows update agent with outdated version Win7 RTM and lower" -LimitingCollectionName $Collection13.Name -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection26.Name -QueryExpression $Collection26.Query -RuleName $Collection26.Name
Write-host *** Collection $Collection26.Name created ***

New-CMDeviceCollection -Name $Collection27.Name -Comment "All systems with windows update agent with outdated version Win7 SP1 and higher" -LimitingCollectionName $Collection13.Name -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection27.Name -QueryExpression $Collection27.Query -RuleName $Collection27.Name
Write-host *** Collection $Collection27.Name created ***

New-CMDeviceCollection -Name $Collection28.Name -Comment "All Android modible devices" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection28.Name -QueryExpression $Collection28.Query -RuleName $Collection28.Name
Write-host *** Collection $Collection28.Name created ***

New-CMDeviceCollection -Name $Collection29.Name -Comment "All Iphone modible devices" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection29.Name -QueryExpression $Collection29.Query -RuleName $Collection29.Name
Write-host *** Collection $Collection29.Name created ***

New-CMDeviceCollection -Name $Collection30.Name -Comment "All Ipad mobile devices" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection30.Name -QueryExpression $Collection30.Query -RuleName $Collection30.Name
Write-host *** Collection $Collection30.Name created ***

New-CMDeviceCollection -Name $Collection31.Name -Comment "All Windows 8 mobile devices" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection31.Name -QueryExpression $Collection31.Query -RuleName $Collection31.Name
Write-host *** Collection $Collection31.Name created ***

New-CMDeviceCollection -Name $Collection32.Name -Comment "All Windows 8.1 mobile devices" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection32.Name -QueryExpression $Collection32.Query -RuleName $Collection32.Name
Write-host *** Collection $Collection32.Name created ***

New-CMDeviceCollection -Name $Collection33.Name -Comment "All Windows RT mobile devices" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection33.Name -QueryExpression $Collection33.Query -RuleName $Collection33.Name
Write-host *** Collection $Collection33.Name created ***

New-CMDeviceCollection -Name $Collection34.Name -Comment "All systems with client state disabled" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection34.Name -QueryExpression $Collection34.Query -RuleName $Collection34.Name
Write-host *** Collection $Collection34.Name created ***

New-CMDeviceCollection -Name $Collection35.Name -Comment "All systems with 32-bit system type" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection35.Name -QueryExpression $Collection35.Query -RuleName $Collection35.Name
Write-host *** Collection $Collection35.Name created ***

New-CMDeviceCollection -Name $Collection36.Name -Comment "All systems with 64-bit system type" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection36.Name -QueryExpression $Collection36.Query -RuleName $Collection36.Name
Write-host *** Collection $Collection36.Name created ***

New-CMDeviceCollection -Name $Collection37.Name -Comment "All systems with SCCM client version R2 CU1 installed" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection37.Name -QueryExpression $Collection37.Query -RuleName $Collection37.Name
Write-host *** Collection $Collection37.Name created ***

New-CMDeviceCollection -Name $Collection38.Name -Comment "All systems with SCCM client version R2 CU2 installed" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection38.Name -QueryExpression $Collection38.Query -RuleName $Collection38.Name
Write-host *** Collection $Collection38.Name created ***

New-CMDeviceCollection -Name $Collection39.Name -Comment "All systems with SCCM client version R2 CU3 installed" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection39.Name -QueryExpression $Collection39.Query -RuleName $Collection39.Name
Write-host *** Collection $Collection39.Name created ***

New-CMDeviceCollection -Name $Collection40.Name -Comment "All systems with SCCM client version R2 CU4 installed" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection40.Name -QueryExpression $Collection40.Query -RuleName $Collection40.Name
Write-host *** Collection $Collection40.Name created ***

New-CMDeviceCollection -Name $Collection41.Name -Comment "All systems with SCCM client version R2 CU5 installed" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection41.Name -QueryExpression $Collection41.Query -RuleName $Collection41.Name
Write-host *** Collection $Collection41.Name created ***

New-CMDeviceCollection -Name $Collection42.Name -Comment "All systems with SCCM client version R2 CU0 installed" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection42.Name -QueryExpression $Collection42.Query -RuleName $Collection42.Name
Write-host *** Collection $Collection42.Name created ***

New-CMDeviceCollection -Name $Collection43.Name -Comment "All systems with SCCM client version R2 SP1 installed" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection43.Name -QueryExpression $Collection43.Query -RuleName $Collection43.Name
Write-host *** Collection $Collection43.Name created ***

New-CMDeviceCollection -Name $Collection44.Name -Comment "All systems with SCCM client version R2 SP1 CU1 installed" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection44.Name -QueryExpression $Collection44.Query -RuleName $Collection44.Name
Write-host *** Collection $Collection44.Name created ***

New-CMDeviceCollection -Name $Collection45.Name -Comment "All workstations with Windows 10 operating system" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection45.Name -QueryExpression $Collection45.Query -RuleName $Collection45.Name
Write-host *** Collection $Collection45.Name created ***

New-CMDeviceCollection -Name $Collection46.Name -Comment "All systems with SCCM client version R2 SP1 CU2 installed" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection46.Name -QueryExpression $Collection46.Query -RuleName $Collection46.Name
Write-host *** Collection $Collection46.Name created ***

New-CMDeviceCollection -Name $Collection47.Name -Comment "All systems with SCCM client version 1511 installed" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection47.Name -QueryExpression $Collection47.Query -RuleName $Collection47.Name
Write-host *** Collection $Collection47.Name created ***

New-CMDeviceCollection -Name $Collection48.Name -Comment "All laptops with Dell manufacturer" -LimitingCollectionName $Collection9.Name -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection48.Name -QueryExpression $Collection48.Query -RuleName $Collection48.Name
Write-host *** Collection $Collection48.Name created ***

New-CMDeviceCollection -Name $Collection49.Name -Comment "All laptops with Lenovo manufacturer" -LimitingCollectionName $Collection9.Name -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection49.Name -QueryExpression $Collection49.Query -RuleName $Collection49.Name
Write-host *** Collection $Collection49.Name created ***

New-CMDeviceCollection -Name $Collection50.Name -Comment "All laptops with HP manufacturer" -LimitingCollectionName $Collection9.Name -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection50.Name -QueryExpression $Collection50.Query -RuleName $Collection50.Name
Write-host *** Collection $Collection50.Name created ***

New-CMDeviceCollection -Name $Collection51.Name -Comment "All systems with SCCM client version R2 SP1 CU3 installed" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection51.Name -QueryExpression $Collection51.Query -RuleName $Collection51.Name
Write-host *** Collection $Collection51.Name created ***

New-CMDeviceCollection -Name $Collection52.Name -Comment "All systems with SCCM client version 1602 installed" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection52.Name -QueryExpression $Collection52.Query -RuleName $Collection52.Name
Write-host *** Collection $Collection52.Name created ***

New-CMDeviceCollection -Name $Collection53.Name -Comment "All systems with SCCM client version 1606 installed" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection53.Name -QueryExpression $Collection53.Query -RuleName $Collection53.Name
Write-host *** Collection $Collection53.Name created ***

New-CMDeviceCollection -Name $Collection54.Name -Comment "All Microsoft Surface 3" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection54.Name -QueryExpression $Collection54.Query -RuleName $Collection54.Name
Write-host *** Collection $Collection54.Name created ***

New-CMDeviceCollection -Name $Collection55.Name -Comment "All Microsoft Surface 4" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection55.Name -QueryExpression $Collection55.Query -RuleName $Collection55.Name
Write-host *** Collection $Collection55.Name created ***

New-CMDeviceCollection -Name $Collection56.Name -Comment "All Windows Phone 10" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection56.Name -QueryExpression $Collection56.Query -RuleName $Collection56.Name
Write-host *** Collection $Collection56.Name created ***

New-CMDeviceCollection -Name $Collection57.Name -Comment "All Mobile Devices" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection57.Name -QueryExpression $Collection57.Query -RuleName $Collection57.Name
Write-host *** Collection $Collection57.Name created ***

New-CMDeviceCollection -Name $Collection58.Name -Comment "All workstations with Windows 10 operating system v1507" -LimitingCollectionName $Collection13.Name -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection58.Name -QueryExpression $Collection58.Query -RuleName $Collection58.Name
Write-host *** Collection $Collection58.Name created ***

New-CMDeviceCollection -Name $Collection59.Name -Comment "All workstations with Windows 10 operating system v1511" -LimitingCollectionName $Collection13.Name -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection59.Name -QueryExpression $Collection59.Query -RuleName $Collection59.Name
Write-host *** Collection $Collection59.Name created ***

New-CMDeviceCollection -Name $Collection60.Name -Comment "All workstations with Windows 10 operating system v1607" -LimitingCollectionName $Collection13.Name -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection60.Name -QueryExpression $Collection60.Query -RuleName $Collection60.Name
Write-host *** Collection $Collection60.Name created ***

New-CMDeviceCollection -Name $Collection61.Name -Comment "All workstations with Windows 10 CB" -LimitingCollectionName $Collection13.Name -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection61.Name -QueryExpression $Collection61.Query -RuleName $Collection61.Name
Write-host *** Collection $Collection61.Name created ***

New-CMDeviceCollection -Name $Collection62.Name -Comment "All workstations with Windows 10 CBB" -LimitingCollectionName $Collection13.Name -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection62.Name -QueryExpression $Collection62.Query -RuleName $Collection62.Name
Write-host *** Collection $Collection62.Name created ***

New-CMDeviceCollection -Name $Collection63.Name -Comment "All workstations with Windows 10 LTSB" -LimitingCollectionName $Collection13.Name -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection63.Name -QueryExpression $Collection63.Query -RuleName $Collection63.Name
Write-host *** Collection $Collection63.Name created ***

New-CMDeviceCollection -Name $Collection64.Name -Comment "Windows 10 Support State - Current" -LimitingCollectionName $Collection13.Name -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection64.Name -QueryExpression $Collection64.Query -RuleName $Collection64.Name
Write-host *** Collection $Collection64.Name created ***

New-CMDeviceCollection -Name $Collection65.Name -Comment "Windows 10 Support State - Expired Soon" -LimitingCollectionName $Collection13.Name -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection65.Name -QueryExpression $Collection65.Query -RuleName $Collection65.Name
Write-host *** Collection $Collection65.Name created ***

New-CMDeviceCollection -Name $Collection66.Name -Comment "Windows 10 Support State - Expired" -LimitingCollectionName $Collection13.Name -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection66.Name -QueryExpression $Collection66.Query -RuleName $Collection66.Name
Write-host *** Collection $Collection66.Name created ***

New-CMDeviceCollection -Name $Collection67.Name -Comment "All Servers with Windows 2016" -LimitingCollectionName $Collection10.Name -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection67.Name -QueryExpression $Collection67.Query -RuleName $Collection67.Name
Write-host *** Collection $Collection67.Name created ***

New-CMDeviceCollection -Name $Collection68.Name -Comment "All systems with SCCM client version 1610 installed" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection68.Name -QueryExpression $Collection68.Query -RuleName $Collection68.Name
Write-host *** Collection $Collection68.Name created ***

New-CMDeviceCollection -Name $Collection69.Name -Comment "All systems with SCCM client version 1702 installed" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection69.Name -QueryExpression $Collection69.Query -RuleName $Collection69.Name
Write-host *** Collection $Collection69.Name created ***

New-CMDeviceCollection -Name $Collection70.Name -Comment "All systems with Linux" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection70.Name -QueryExpression $Collection70.Query -RuleName $Collection70.Name
Write-host *** Collection $Collection70.Name created ***

New-CMDeviceCollection -Name $Collection71.Name -Comment "All workstations with MAC OSX" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection71.Name -QueryExpression $Collection71.Query -RuleName $Collection71.Name
Write-host *** Collection $Collection71.Name created ***

New-CMDeviceCollection -Name $Collection72.Name -Comment "All systems with SCCM client version 1706 installed" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection72.Name -QueryExpression $Collection72.Query -RuleName $Collection72.Name
Write-host *** Collection $Collection72.Name created ***

New-CMDeviceCollection -Name $Collection73.Name -Comment "All systems with SCCM client version 1710 installed" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection73.Name -QueryExpression $Collection73.Query -RuleName $Collection73.Name
Write-host *** Collection $Collection73.Name created ***



#Move the collection to the right folder
$FolderPath = $SiteCode.Name + ":\DeviceCollection\" + $CollectionFolder.Name
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
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection56.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection57.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection58.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection59.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection60.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection61.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection62.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection63.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection64.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection65.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection66.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection67.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection68.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection69.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection70.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection71.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection72.Name)
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection73.Name)

}
catch{
$Error1 = 1
}
Finally{
    If ($Error1 -eq 1){
        Write-host "-----------------"
        Write-host -ForegroundColor Red "Script has already been run or a collection name already exist. Delete All Operational collection before re-executing the script !"
        Write-host "-----------------"
        Pause
    }
    Else{
        Write-host "-----------------"
        Write-Host -ForegroundColor Green "Script execution completed without errors. Operational Collections created sucessfully"
        Write-host "-----------------"
        Pause
        }
        }