# Purpose: create-testcoll — General-purpose PowerShell utilities.


#Load Configuration Manager PowerShell Module
Import-module ($Env:SMS_ADMIN_UI_PATH.Substring(0,$Env:SMS_ADMIN_UI_PATH.Length-5) + '\ConfigurationManager.psd1')

#Get SiteCode
$SiteCode = Get-PSDrive -PSProvider CMSITE
Set-location $SiteCode":"

#Error Handling and output
Clear-Host
$ErrorActionPreference= 'SilentlyContinue'
$Error1 = 0

#Refresh Schedule - normal default is 7 days
$Schedule = New-CMSchedule –RecurInterval Days –RecurCount 21

#List of Collections Query
$Collection1 = @{Name = "ZZZTEST zzz"; Query =  "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ADSiteName = 'AGH'"}

#Create Defaut Folder 
#$CollectionFolder = @{Name = "AD SITES"; ObjectType = 5000; ParentContainerNodeId = 0}
# Set-WmiInstance -Namespace "root\sms\site_$($SiteCode.Name)" -Class "SMS_ObjectContainerNode" -Arguments $CollectionFolder

#Create Default limiting collections
$LimitingCollection = "All Systems"

#Create Collection
try{
New-CMDeviceCollection -Name $Collection1.Name -Comment "zzzTEST- DELETE ANYTIME" -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection1.Name -QueryExpression $Collection1.Query -RuleName $Collection1.Name
Write-host *** Collection $Collection1.Name created ***



#Move the collection to the right folder
$FolderPath = $SiteCode.Name + ":\DeviceCollection\Informational\AD SITES"
Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection1.Name)

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