# Purpose: Create-CollCSVinput — General-purpose PowerShell utilities.
# use a CSV file to define new collections
# 


#Load Configuration Manager PowerShell Module
Import-module ($Env:SMS_ADMIN_UI_PATH.Substring(0,$Env:SMS_ADMIN_UI_PATH.Length-5) + '\ConfigurationManager.psd1')

#Get SiteCode - auto detects SCCM site - prevents typos
$SiteCode = Get-PSDrive -PSProvider CMSITE
Set-location $SiteCode":"

#Error Handling and output
Clear-Host
$ErrorActionPreference= 'SilentlyContinue'
$Error1 = 0

#Refresh Schedule  - default is 7 days
# could add default Refresh to CSV and then change as needed in the CSV - if set in CSV this line is not needed..
$Schedule = New-CMSchedule –RecurInterval Days –RecurCount 7

# use import-csv to pull CollName, CollPath, Comment, Limit, Query 
# line to create collection Query
#$Collection1 = @{Name = "BAT All Systems"; Query =  "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ADSiteName = 'BAT'"}

#Create Defaut Folder 
# Not sure if this is desired
# if not used the folder would need to be manually created and added tothe CollPath
$CollectionFolder = @{Name = "AD SITES"; ObjectType = 5000; ParentContainerNodeId = 0}
Set-WmiInstance -Namespace "root\sms\site_$($SiteCode.Name)" -Class "SMS_ObjectContainerNode" -Arguments $CollectionFolder

#Create Default limiting collections - this gets new value from CSV
# may be simpler (more reliable) to have CSV file use default vaule and then change as needed
$CollLimit = "All Systems"

# Write-host is just used to either show progress while running or for testing during development

$NewCollData = (import-csv c:\temp\NewColl.csv)
#CollLimt is the name of the limiting collection - default should be ALL Systems
#routine to run a create and move for each line in the CSV file

	foreach ($CollItem in $NewCollData) {
		$CollName = $CollItem.CollName
		$CollPath = $CollItem.CollPath
		$CollComment = $CollItem.Comment
		$CollLimit = $CollItem.Limit
		$CollQuery = $CollItem.Query
		
	$Collection1 = @{Name = $CollName; Query =  $CollQuery}	
		#Create Collection
try{
New-CMDeviceCollection -Name $Collection1.Name -Comment $CollComment -LimitingCollectionName $CollLimit -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection1.Name -QueryExpression $Collection1.Query -RuleName $Collection1.Name
# write host not needed unless you just want to see the results as it runs
Write-host *** Collection $Collection1.Name created ***

#Move the new collection to the right folder
# use a variable in the csv to define path...  $CollPath  default in CSV shouldbe DeviceCollection  then add \foldername\subfoldername if needed
$FolderPath = $SiteCode.Name + ":\" + $CollPath

write-host ******  Folder Path is:  $FolderPath

Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection1.Name)
}
catch{
$Error1 = 1
}
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