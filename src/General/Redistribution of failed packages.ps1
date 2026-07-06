#Script written by Robin Toloch
#Version 1.1

<#
.SYNOPSIS
Redistributes content of failed packaged on distribution points.

.DESCRIPTION
This script is intended to update content of packages which state is either 3 (failed, set by default) or 0-6 (passed by parameter).
Action is triggered on all distribution points that are present on main site (default), or that are present on main site and its child sites, or particular DPs.
All actions are saved to a log file at SYSTEMDRIVE:\temp\Redistribution_Of_Failed_Packages.log. File is created automatically as well as temp folder, if either of them do not exist.

.PARAMETER mainSite
Required string parameter

This paramater sets main site that the script will work with. 
Please make sure the site you pass to script corresponds with the server site assignment you run it on, in other words namespace "root\sms\site_MAINSITE" must exist!

.PARAMETER DriveWithSCCMInstallation
Reuired string parameter

This parameter tells the script the drive location of SCCM module.
Path looks like this if parameter is set to "D" - D:\Program Files\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1

.PARAMETER stateIDs
Optional integer parameter, default value is 3.

A single number 0-6 or list of numbers. Packages which state equals to one of the numbers will be redistributed.
See table at https://msdn.microsoft.com/en-us/library/cc143014.aspx for State explanation.

.PARAMETER checkOnlyMainSite
Optional boolean parameter, default value is true

This parameter tells the script whether it should redistribute pacakges only on distribution points at main site or main site and its child sites.

.PARAMETER DPsNames
Optional string parameter, no default value

A single distribution point name or list of distribution point names. The script will then update content on specified distribution point(s) instead of going through all DPs per site.

.EXAMPLE

Update content for main site CS1. Check packages with state 3. SCCM Module is on drive D.
Redistribution of failed packages.ps1 -mainSite CS1 -DriveWithSCCMInstallation D

.EXAMPLE

Update content for main site CS1 and its child sites. Check packages with state 3 and 4. SCCM Module is on drive D.
Redistribution of failed packages.ps1 -mainSite CS1 -DriveWithSCCMInstallation D -stateIDs 3,4 -checkOnlyMainSite $false

.EXAMPLE

Update content for distribution points TESTSCCMDP001 and TESTSCCMDP002 which are at CS1 site. Check packages with state 3. SCCM Module is on drive D.
Redistribution of failed packages.ps1 -mainSite CS1 -DriveWithSCCMInstallation D -DPsNames TESTSCCMDP001,TESTSCCMDP002

Version: 1.1
Requires: PowerShell 3.0 or higher and SCCM cmdlet library (https://www.microsoft.com/en-us/download/details.aspx?id=46681)

Known bugs:
You may encounter quota violation errors, please visit https://blogs.technet.microsoft.com/askperf/2008/09/16/memory-and-handle-quotas-in-the-wmi-provider-service/ for workarounds.
This may not happen while launching the script using PowerShell ISE.

.LINK
https://gallery.technet.microsoft.com/scriptcenter/Update-content-of-failed-19adcdb2

#>


[CmdletBinding()]
Param (
    [Parameter(Mandatory=$true)]
    [ValidateNotNull()]
    [string]$mainSite,

    [Parameter(Mandatory=$true)]
    [ValidateNotNull()]
    [string]$DriveWithSCCMInstallation,

    [string[]]$stateIDs="3",

    [boolean]$checkOnlyMainSite=$true,

    [string[]]$DPsNames
)

#Function LogToCMTraceFile is used to log to $logFile, which is defined below, default patch is SystemDrive\Temp\Redistribution_Of_Failed_Packages.log
function LogToCMTraceFile {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [string]$message,

        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [int]$type,

        #1 - information
        #2 - warning
        #3 - error
        #4 - verbose


        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [string]$component,

        [Parameter(Mandatory=$false)]
        [int]$thread,

        [Parameter(Mandatory=$false)]
        [string]$file
    )
    If($type -lt 1 -or $type -gt 4) {
        Throw "Type must be between 1-4"
    }
    If($file -ne "" -and $thread -eq ""){
        Throw "You must specify thread, if you wish to use -file switch"
    }

    $Time = (Get-Date -Format "HH:mm:ss.fff-fff")
    $Date = (Get-Date -Format "MM-dd-yyyy")

    $LogStructure = "<![LOG[$($message)]LOG]!><time=""$($Time)"" date=""$($Date)"" component=""$($component)"" context="""" type=""$($type)"" thread=""$($hread)"" file=""$($file)"">"

    Out-File -FilePath $logFile -Append -InputObject $LogStructure -Force -Encoding utf8
}

$ErrorActionPreference = "Stop"

#check if folder exists, it is created, if it doesn't
if ((test-path "$($env:SystemDrive)\Temp") -eq $false){
    new-item "$($env:SystemDrive)\Temp" -ItemType Directory -Force | Out-Null #to suppress output of new-item cmdlet
}

$logFile = "$($env:SystemDrive)\Temp\Redistribution_Of_Failed_Packages.log"

#initialization part

LogToCMTraceFile -message "------------------------------------------------------------------------" -type 1 -component "Initialization"
LogToCMTraceFile -message "Script launched on $(Get-Date) " -type 1 -component "Initialization"
LogToCMTraceFile -message "Script launched by $($env:UserDomain)\$($env:USERNAME)" -type 1 -component "Initialization"

#initialize script by loading SCCM module and setting location to site passed to script
try {
    Import-Module "$($DriveWithSCCMINstallation):\Program Files\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1"
    Set-Location "$($mainSite):"
    
    if(!$checkOnlyMainSite){
        LogToCMTraceFile -message "Successfully initialized script to redistribute wrong packages on distribution points at $($mainSite) and its child sites. Check only main site is set to false." -type 1 -component "Initialization"
    }
    else {
        LogToCMTraceFile -message "Successfully initialized script to redistribute wrong packages on distribution points at $($mainSite). Check only main site is set to true." -type 1 -component "Initialization"
    }

    LogToCMTraceFile -message "SCCM Module loaded from: $($DriveWithSCCMINstallation):\Program Files\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1" -type 1 -component "Initialization"
    LogToCMTraceFile -message "Main site is set to: $($mainSite)" -type 1 -component "Initialization"
}
catch{
    LogToCMTraceFile -message "Failed to initialize script to redistribute wrong packages on distribution points at $($mainSite) and its child sites" -type 3 -component "Initialization"
    LogToCMTraceFile -message "Please check SCCM Module at: $($DriveWithSCCMINstallation):\Program Files\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1" -type 2 -component "Initialization"
    LogToCMTraceFile -message "Please check that main site $($mainSite) is accessible" -type 2 -component "Initialization"
    Exit
}

if (!$DPsNames){
    try {
        #get main site code
        $mainCMsite = Get-CMSite -SiteCode $mainSite | select sitecode

        #get all site codes which report to main site and append main site to it
        #condition set to do such thing only if checkonlymainsite is false
        if(!$checkOnlyMainSite) {
            $allSitesAtLocation = Get-CMSite | where reportingsitecode -eq $mainSite | select sitecode
            $allSitesAtLocation += $mainCMsite
        }
        else {
            $allSitesAtLocation = $mainCMsite
        }
    }
    catch {
        LogToCMTraceFile -message "An error occured while trying to retrieve sites. Script will attempt to continue. Error message: $($_.Exception.Message)" -type 2 -component "Initialization"
    }
    $ErrorActionPreference = "SilentlyContinue"
    #Quickly go through all sites and write them to log
    #This part is outside of try-catch because if an error occured, sites would not be written to log file. Leaving user without any of sites that will be processed later
    [string]$sitesToLog=""
    foreach ($site in $allSitesAtLocation){
        $sitesToLog+="$($site.sitecode), "
    }

    $sitesToLog = $sitesToLog.Substring(0,$sitesToLog.Length-2)
    LogToCMTraceFile -message "Found sites: $($sitesToLog)" -type 1 -component "Initialization"
}
else {
    [string]$dpsToLog=""
    foreach ($dpP in $DPsNames){
        $dpsToLog+="$($dpP), "
    }
    $dpsToLog = $dpsToLog.Substring(0,$dpsToLog.Length-2)
    LogToCMTraceFile -message "Script will check following distribution points: $($dpsToLog)" -type 1 -component "Initialization"
}

[boolean]$wrongID=$false

[string]$statesToLog=""
foreach ($id in $stateIDs){
    $statesToLog+="$($id), "

    if($id -lt 0 -or $id -gt 6){
        LogToCMTraceFile -message "Bad package state id. It must be between 0-6! Wrongly defined id: $($id)" -type 2 -component "Initialization"
        $wrongID = $true
    }
}

if (!$wrongID) {
    $statesToLog = $statesToLog.Substring(0,$statesToLog.Length-2)
    LogToCMTraceFile -message "Script will update packages with state: $($statesToLog)" -type 1 -component "Initialization"
    LogToCMTraceFile -message "------------------------------------------------------------------------" -type 1 -component "Initialization"
}
else {
    $statesToLog = $statesToLog.Substring(0,$statesToLog.Length-2)
    LogToCMTraceFile -message "Please review defined states: $($statesToLog)" -type 2 -component "Initialization"
    LogToCMTraceFile -message "Initialization failed - quitting script" -type 3 -component "Initialization"
    Exit
}

if ($DPsNames){
    $mainCMsite = Get-CMSite -SiteCode $mainSite | select sitecode
    $allSitesAtLocation = $mainCMsite
}

$ErrorActionPreference = "Stop"

#go site by site
foreach ($site in $allSitesAtLocation) {
    

    #find all distribution points on current site OR get DPs from parameter
    LogToCMTraceFile -message "Processing site $($site.SiteCode)" -type 1 -component "Site processing"

    if (!$DPsNames){
        try {
            $DPsAtSite = Get-CMDistributionPoint -SiteCode $site.SiteCode | select networkOSPath
            LogToCMTraceFile -message "*** Successfully retrieved DPs from site $($site.SiteCode)" -type 1 -component "Site processing - Get DPs"
        }
        catch {
            LogToCMTraceFile -message "### Failed to retrieve DPs from site $($site.SiteCode). Script will attempt to continue. Error message: $($_.Exception.Message)" -type 3 -component "Site processing - Get DPs"
        }
    }
    else {
        $DPsAtSite = $DPsNames
    }

    #go dp by dp
    foreach ($DPatSite in $DPsAtSite) {
        #find all wrong packages on current distribution point
        try {
            if (!$DPsNames) { 
                $filteredNameForQuery = ($DPatSite.networkospath).Replace("\","")
            }
            else {
                $filteredNameForQuery = $DPatSite
            }
            LogToCMTraceFile -message "****** Processing distribution point $($filteredNameForQuery)" -type 1 -component "DP processing"
            $failedPkgs = Get-WmiObject -Namespace "root\sms\site_$mainSite" -class SMS_PackageStatusDistPointsSummarizer | where {$_.State -in $stateIDs -and $_.ServerNalPath -like "*$filteredNameForQuery*"} | select PackageID
            LogToCMTraceFile -message "********* There are $($failedPkgs.Count) wrong packages" -type 1 -component "DP processing"
        }
        catch {
            LogToCMTraceFile -message "######### Loading wrong packages on distribution point $($filteredNameForQuery) was not successful. Script will attempt to continue. Error message: $($_.Exception.Message)" -type 2 -component "DP processing"
        }

        #if there is more than 0 packages, continue
        if ($failedPkgs.Count -gt 0) {
            foreach ($failedPkg in $failedPkgs) {

            #go package by package and try updating its content
             try {
                 LogToCMTraceFile -message "********* Updating package id:$($failedPkg.PackageID)" -type 1 -component "DP processing - package update"
                 if (!$DPsNames) { 
                    $pkgOnDP = Get-WmiObject -Namespace "root\sms\site_$mainSite" -class SMS_DistributionPoint | where {$_.PackageID -eq $failedPkg.PackageID -and $_.ServerNalPath -like "*$filteredNameForQuery*" -and $_.SiteCode -eq $site.SiteCode}
                 }
                 else {
                    $pkgOnDP = Get-WmiObject -Namespace "root\sms\site_$mainSite" -class SMS_DistributionPoint | where {$_.PackageID -eq $failedPkg.PackageID -and $_.ServerNalPath -like "*$filteredNameForQuery*"}
                 }
                 $pkgOnDP.RefreshNow = $true
                 $pkgOnDP.Put()
                 LogToCMTraceFile -message "********* Successfully triggered an update of package id:$($failedPkg.PackageID)" -type 1 -component "DP processing - package update"
             }
             catch {
                 LogToCMTraceFile -message "######### Failed to update package id:$($failedPkg.PackageID). Script will attempt to continue. Error message: $($_.Exception.Message)" -type 2 -component "DP processing - package update"
             }
            }
        }
    }

    LogToCMTraceFile -message "----------------------------$($site.SiteCode) completed-------------------------------" -type 1 -component "Site completed"
}
LogToCMTraceFile -message "Script has finished." -type 1 -component "Completed"