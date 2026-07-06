# Purpose: Create-SCCMClientVersionCollections — Configuration Manager collections and deployments.
# ----------------------------------------------------------------------------- 
# Blog: http://www.ronnipedersen.com 
# Twitter: @ronnipedersen 
# Date: 07/07-2017 
# ----------------------------------------------------------------------------- 

##*===============================================
##* DECLARATIONS
##*===============================================

# Declaring variables
$SiteCode = "P01" 
$LimitingCollectionName = "All Systems"
 
##*===============================================
##* IMPORT CONFIGURATION MANAGER MODULE
##*=============================================== 

# Import the ConfigurationManager.psd1 module  
Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1"  
 
# Set the current location to be the site code. 
Set-Location $SiteCode":\"  
 
##*===============================================
##* CREATE COLLECTIONS
##*===============================================

# Create Update Schedules for the collections
$Schedule = New-CMSchedule -Start "01/01/2017 9:00 PM" -DayOfWeek Sunday -RecurCount 1

# Get All Client Versions
$ClientVersions = Get-CMDevice -CollectionName "All Desktop and Server Clients" | Group ClientVersion

# Create a Collection for each Client Version
$ClientVersions | foreach {
    $CMVersion = $_.Name
    $CollectionName = "#CLI - Client Version = $CMVersion"
    $CollectionExist = Get-CMDeviceCollection -Name "$CollectionName"

    If ($CollectionExist) {
        Write-Host "The collection $CollectionName already exist"
        }
    Else {
        Write-Host "Creating collection"
        New-CMDeviceCollection -Name $CollectionName -LimitingCollectionName $LimitingCollectionName -RefreshSchedule $Schedule -RefreshType Periodic
        Add-CMDeviceCollectionQueryMembershipRule -CollectionName $CollectionName -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion = '$CMVersion'" -RuleName "Client Version = $CMVersion"
        Write-Host "Collection $CollectionName created"
        }
    } 

# ----------------------------------------------------------------------------- 