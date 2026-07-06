# Purpose: Deploy-Application — PowerShell automation.

Param (
	[ValidateSet("Install","Uninstall")] 
	[string]$DeploymentType = "Install",
	[ValidateSet("Interactive","Silent","NonInteractive")]
	[string]$DeployMode = "silent",
	[switch] $AllowRebootPassThru = $False,
	[switch] $TerminalServerMode = $false,
    [switch] $ForceRestartMode = $True,
    [string] $Defaulthomepage = "http://www.google.com",
    [ValidateSet("true","false")] 
    [string] $Checkdefaultbrowser = "false",
    [ValidateSet("true","false")] 
    [string] $Enableapplicationupdates = "false",
    [ValidateSet("true","false")] 
    [string] $Disableknowyourrights = "false",
    [Version] $versionnumber = "30.0"
)

#*===============================================
#* VARIABLE DECLARATION
Try {
#*===============================================

#*===============================================
# Variables: Application

$appVendor = "Mozilla"
$appName = "Mozilla Firefox"
$appVersion = [version]$versionnumber
$appArch = ""
$appLang = "EN"
$appRevision = "01"
$appScriptVersion = "1.0.0"
$appScriptDate = "02/07/2014"
$appScriptAuthor = "Topaz Paul"
$InstalledVersion32 = "$env:SystemDrive\Program Files (x86)\Mozilla Firefox\firefox.exe"
$InstalledVersion64 = "$env:SystemDrive\Program Files\Mozilla Firefox\firefox.exe"

#*===============================================
# Variables: Script - Do not modify this section

$deployAppScriptFriendlyName = "Deploy Application"
$deployAppScriptVersion = [version]"3.1.2"
$deployAppScriptDate = "04/30/2014"
$deployAppScriptParameters = $psBoundParameters

# Variables: Environment
$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Definition
# Dot source the App Deploy Toolkit Functions
."$scriptDirectory\AppDeployToolkit\AppDeployToolkitMain.ps1"
."$scriptDirectory\SupportFiles\Get-ApplicationInfo.ps1"
."$scriptDirectory\SupportFiles\Get-PendingReboot.ps1"

#*===============================================
#* END VARIABLE DECLARATION
#*===============================================

#*===============================================
#* PRE-INSTALLATION
If ($deploymentType -ne "uninstall") { $installPhase = "Pre-Installation"
#*===============================================
    # Is reboot pending
    
    if ($(Get-PendingReboot).RebootPending) {  
        
            Write-Log "The system is pending reboot from a previous install or uninstall."
        
    }

    # Prompt the user to close the following applications if they are running:
    
    Show-InstallationWelcome -CloseApps "firefox" -AllowDefer -DeferTimes 3 -CloseAppsCountdown "120"
    
    # Show Progress Message (with the default message)
    
    Show-InstallationProgress 
    
    # Remove application Mozilla Maintenance Service

    $VarUInstallMS = $((Get-ApplicationInfo|Where-Object {$_.Product -match "Mozilla Maintenance Service"}).Uninstall)-replace '"', ''

    if ($VarUInstallMS) {

        Write-Log "Unistalling Mozilla Maintenance Service. $VarUInstall is the uninstall path"

        Execute-Process -FilePath "$VarUInstallMS" -Arguments "/S" -WindowStyle Hidden

    }
    
    # Query the computer to find the uninstall string
    
    $VarUInstall = $((Get-ApplicationInfo|Where-Object {$_.Product -match "Mozilla Firefox"}).Uninstall)-replace '"', ''
    

    #Unistall previous versions of Mozilla Firefox. 
    
    if (Test-Path $InstalledVersion32) {  

       $file32 = get-item $InstalledVersion32
       
       $version32 = [version]$($($file32.versionInfo.Productversion -replace ",", ".") -replace "r", ".")
       
           If (($version32 -lt $appVersion)) {
                
                Execute-Process -FilePath "$VarUInstall" -Arguments "/S" -WindowStyle Hidden
           
           }  ElseIf (($version32 -ge $appVersion)) {
           
                Write-Log "An equal or greater version of $appName is already installed on this machine"
                
                Exit-Script -ExitCode 0
           
           }  
       } 
       
     if (Test-Path $InstalledVersion64) {  
     
           $file64 = get-item $InstalledVersion64 
           
           $version64 = [version]$($($file64.versionInfo.Productversion -replace ",", ".") -replace "r", ".")
           
           If (($version64 -lt $appVersion)) {
                
                Execute-Process -FilePath "$VarUInstall" -Arguments "/S" -WindowStyle Hidden
           
           } ElseIf (($version64 -ge $appVersion)) {
           
                Write-Log "An equal or greater version of $appName is already installed on this machine"
                
                Exit-Script -ExitCode 0
           
           }
        } 
        

#*===============================================
#* INSTALLATION 
$installPhase = "Installation"
#*===============================================

    # Install Mozilla Firefox.
    
    Execute-Process -FilePath "Firefox-Setup.exe" -Arguments "/S" -WindowStyle Hidden



#*===============================================
#* POST-INSTALLATION
$installPhase = "Post-Installation"
#*===============================================

if (Test-Path $InstalledVersion32) {  

    if (!(Test-Path "$envProgramFilesX86\Mozilla Firefox\Browser")) {
    
        New-Folder -path "$envProgramFilesX86\Mozilla Firefox\Browser"
    
    }
    
    if (Test-Path "$envProgramFilesX86\Mozilla Firefox\Browser\override.ini") {Remove-File -Path "$envProgramFilesX86\Mozilla Firefox\Browser\override.ini"}
    
    Copy-File -Path "$dirFiles\override.ini" -Destination "$envProgramFilesX86\Mozilla Firefox\Browser\"
    
    if (Test-Path "$envProgramFilesX86\Mozilla Firefox\mozilla.cfg") {Remove-File -Path "$envProgramFilesX86\Mozilla Firefox\mozilla.cfg"}
    
    (Get-Content "$dirFiles\mozilla-Template.cfg") |Foreach-Object {$_ -replace "fillme1", """$Defaulthomepage"""}|
    
        Foreach-Object {$_ -replace "fillme2", $Checkdefaultbrowser.tolower()}|Foreach-Object {$_ -replace "fillme3", $Enableapplicationupdates.tolower()}|
        
        Foreach-Object {$_ -replace "fillme4", $Disableknowyourrights.tolower()}|Set-Content "$envProgramFilesX86\Mozilla Firefox\mozilla.cfg"
    
    if (!(Test-Path "$envProgramFilesX86\Mozilla Firefox\Browser\defaults\profile")) {
    
        New-Folder -path "$envProgramFilesX86\Mozilla Firefox\Browser\defaults\profile"
    
    }
    
    if (Test-Path "$envProgramFilesX86\Mozilla Firefox\Browser\defaults\profile\localstore.rdf") {Remove-File -Path "$envProgramFilesX86\Mozilla Firefox\Browser\defaults\profile\localstore.rdf"}
    
    Copy-File -Path "$dirFiles\localstore.rdf" -Destination "$envProgramFilesX86\Mozilla Firefox\Browser\defaults\profile\"
    
    
    if (!(Test-Path "$envProgramFilesX86\Mozilla Firefox\defaults")) {
    
        New-Folder -path "$envProgramFilesX86\Mozilla Firefox\defaults"
    
    }
    
    if (!(Test-Path "$envProgramFilesX86\Mozilla Firefox\defaults\pref")) {
    
        New-Folder -path "$envProgramFilesX86\Mozilla Firefox\defaults\pref"
    
    }
    
    
    if (Test-Path "$envProgramFilesX86\Mozilla Firefox\defaults\pref\channel-prefs.js") {Remove-File -Path "$envProgramFilesX86\Mozilla Firefox\defaults\pref\channel-prefs.js"}
    
    Copy-File -Path "$dirFiles\channel-prefs.js" -Destination "$envProgramFilesX86\Mozilla Firefox\defaults\pref\"
   
} 
  
if (Test-Path $InstalledVersion64) {  

    if (!(Test-Path "$envProgramFiles\Mozilla Firefox\Browser")) {
    
    
        New-Folder -path "$envProgramFiles\Mozilla Firefox\Browser"
    
    }
    
    if (Test-Path "$envProgramFiles\Mozilla Firefox\Browser\override.ini") {Remove-File -Path "$envProgramFiles\Mozilla Firefox\Browser\override.ini"}
    
    
    Copy-File -Path "$dirFiles\override.ini" -Destination "$envProgramFiles\Mozilla Firefox\Browser\"
    
    
    if (Test-Path "$envProgramFiles\Mozilla Firefox\mozilla.cfg") {Remove-File -Path "$envProgramFiles\Mozilla Firefox\mozilla.cfg"}
    
    
    (Get-Content "$dirFiles\mozilla-Template.cfg") |Foreach-Object {$_ -replace "fillme1", """$Defaulthomepage"""}|
    
        Foreach-Object {$_ -replace "fillme2", $Checkdefaultbrowser.tolower()}|Foreach-Object {$_ -replace "fillme3", $Enableapplicationupdates.tolower()}|
        
        Foreach-Object {$_ -replace "fillme4", $Disableknowyourrights.tolower()}|Set-Content "$envProgramFiles\Mozilla Firefox\mozilla.cfg"
    
    
    if (!(Test-Path "$envProgramFiles\Mozilla Firefox\Browser\defaults\profile")) {
    
    
        New-Folder -path "$envProgramFiles\Mozilla Firefox\Browser\defaults\profile"
    
    }
    
    if (Test-Path "$envProgramFiles\Mozilla Firefox\Browser\defaults\profile\localstore.rdf") {Remove-File -Path "$envProgramFiles\Mozilla Firefox\Browser\defaults\profile\localstore.rdf"}
    
    
    Copy-File -Path "$dirFiles\localstore.rdf" -Destination "$envProgramFiles\Mozilla Firefox\Browser\defaults\profile\"
    
    
    if (!(Test-Path "$envProgramFiles\Mozilla Firefox\defaults")) {
    
    
        New-Folder -path "$envProgramFiles\Mozilla Firefox\defaults"
    
    }
    
    if (!(Test-Path "$envProgramFiles\Mozilla Firefox\defaults\pref")) {
    
    
        New-Folder -path "$envProgramFiles\Mozilla Firefox\defaults\pref"
    
    }
    
    
    if (Test-Path "$envProgramFiles\Mozilla Firefox\defaults\pref\channel-prefs.js") {Remove-File -Path "$envProgramFiles\Mozilla Firefox\defaults\pref\channel-prefs.js"}
    
    
    Copy-File -Path "$dirFiles\channel-prefs.js" -Destination "$envProgramFiles\Mozilla Firefox\defaults\pref\"
    
   
} 
       
if (Test-Path "$envPublic\Desktop\Mozilla Firefox.lnk") {Remove-File -Path "$envPublic\Desktop\Mozilla Firefox.lnk"} 

# Remove application Mozilla Maintenance Service

$VarUInstallMS = $((Get-ApplicationInfo|Where-Object {$_.Product -match "Mozilla Maintenance Service"}).Uninstall)-replace '"', ''

if ($VarUInstallMS) {

    Write-Log "Unistalling Mozilla Maintenance Service. $VarUInstall is the uninstall path"

    Execute-Process -FilePath "$VarUInstallMS" -Arguments "/S" -WindowStyle Hidden

}

Refresh-Desktop  


#*===============================================
#* UNINSTALLATION
} ElseIf ($deploymentType -eq "uninstall") { $installPhase = "Uninstallation"
#*===============================================

    # Prompt the user to close the following applications if they are running:
    
    Show-InstallationWelcome -CloseApps "firefox" -AllowDefer -DeferTimes 3 -CloseAppsCountdown "120"
    
    # Show Progress Message (with a message to indicate the application is being uninstalled)
    
    Show-InstallationProgress -StatusMessage "Uninstalling Application $installTitle. Please Wait..." 
    
    # Remove this version Mozilla Firefox
    
    $VarUInstall = $((Get-ApplicationInfo|Where-Object {$_.Product -match "Mozilla Firefox"}).Uninstall)-replace '"', ''
    
    Write-Log "$VarUInstall is the uninstall path"
    
    Execute-Process -FilePath "$VarUInstall" -Arguments "/S" -WindowStyle Hidden
    
    if (Test-Path "$envPublic\Desktop\Mozilla Firefox.lnk") {Remove-File -Path "$envPublic\Desktop\Mozilla Firefox.lnk"}
    
    # Remove application Mozilla Maintenance Service

    $VarUInstallMS = $((Get-ApplicationInfo|Where-Object {$_.Product -match "Mozilla Maintenance Service"}).Uninstall)-replace '"', ''
    
    if ($VarUInstallMS) {

        Write-Log "Unistalling Mozilla Maintenance Service. $VarUInstall is the uninstall path"

        Execute-Process -FilePath "$VarUInstallMS" -Arguments "/S" -WindowStyle Hidden
    
    }
	
	Refresh-Desktop

#*===============================================
#* END SCRIPT BODY
} } Catch {$exceptionMessage = "$($_.Exception.Message) `($($_.ScriptStackTrace)`)"; Write-Log "$exceptionMessage"; Exit-Script -ExitCode 1} # Catch any errors in this script 

Exit-Script -ExitCode 0 # Otherwise call the Exit-Script function to perform final cleanup operations
#*===============================================