# Purpose: AzureAutoReporting — Microsoft Azure cloud resource management.
#Login-AzureRmAccount
#module: AzureRM.Automation - Get latest version using Web Platform Installer
$results = Get-AzureRmAutomationDscNodeReport -AutomationAccountName Automation1 -NodeId 67f0cc70-2e75-11e6-80cf-00155d014746 -ResourceGroupName Default-Storage-SouthCentralUS |
    Out-GridView -PassThru

$results[0] | select *

$NotCompliantNodes = Get-AzureRmAutomationDscNode -Status NotCompliant -AutomationAccountName Automation1 -ResourceGroupName Default-Storage-SouthCentralUS
$notCompliantReports = $NotCompliantNodes |
                         Add-Member -MemberType AliasProperty -Name nodeid -Value id  -PassThru -Force| 
                         Get-AzureRmAutomationDscNodeReport 
$notCompliantReports | ogv

#Use ConvertFrom-JSON to parse the data
$notCompliantReports | Export-AzureRmAutomationDscNodeReportContent -OutputFolder c:\temp\DSCReports
#$json = get-content $t.FullName | ConvertFrom-Json
#$json.statusData | ConvertFrom-Json