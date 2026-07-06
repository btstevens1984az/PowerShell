# Purpose: Add-Applicatons — General-purpose PowerShell utilities.
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# Functions

#----------------------------
FUNCTION Get-ScriptDirectory
#----------------------------
    { 
    $Invocation = (Get-Variable MyInvocation -Scope 1).Value
    Split-Path $Invocation.MyCommand.Path
    } 
    #end function Get-ScriptDirectory

#--------------------------------------
FUNCTION Get-FileGUI($initialDirectory)
#--------------------------------------
	{   
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.ShowHelp = $TRUE
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = "All files (*.*)| *.*"
	#$OpenFileDialog.filter = "Text Files (*.txt) | *.txt |Comma Seperated (*.csv) | *.csv"
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.filename	
    }   

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

########################
# Start of Code Block ##
########################
$MyVersion = "1.0"
$MyModule = "AddApplications"

Write-Host "-----------------------------------------------"
Write-Host "Starting: $MyModule ver. $MyVersion"
Write-Host "-----------------------------------------------"

#Get the location the script is running from
	Write-Host "Getting Script Dir..."
	$scriptFolder = Get-ScriptDirectory
	Write-Host "Script Dir set to: $ScriptFolder"




Add-Type -AssemblyName System.Windows.Forms
$FolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
[void]$FolderBrowser.ShowDialog()
$MDTdsFolder = $FolderBrowser.SelectedPath


# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# Add the MDT PoSh SnapIn if not already
$PSSnapIns = Get-PSSnapin
foreach ($SnapIn in $PSSnapIns) {If ($SnapIn.Name -eq "Microsoft.BDD.PSSnapIn") {$BDDsnapinLoaded = $TRUE}}
$PSModules = Get-Module
FOREACH ($Module in $PSModules) {IF ($Module.Name -eq "MicrosoftDeploymentToolkit") {$BDDsnapinLoaded = $TRUE}}
IF ($BDDsnapinLoaded -ne $TRUE)
    {
    # We need to load the MDT PoSh SnapIn
    Add-PSSnapIn Microsoft.BDD.PSSnapIn -ErrorAction SilentlyContinue 
    }


# Add a new MDT POSJH drive for this share
$MDTpsDrive    = �DS�+((GET-RANDOM 999999999).tostring().trim())
Write-Host "Create the MDT drive" -ForegroundColor DarkCyan
New-PSDrive -Name "$MDTpsDrive" -PSProvider MDTProvider -Root "$MDTdsFolder" -Description "Temp Share" -Verbose #| Add-MDTPersistentDrive -Verbose
Write-Host "* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *" -ForegroundColor Cyan
Write-Host ""
   

# ConfigMgr 2016 1511
    # Extend AD Schema
    Import-MDTApplication -path "$MDTpsDrive`:\Applications" -enable "True" -Name "Configure - Extend AD for ConfigMgr 2016"                    -ShortName "Configure - Extend AD for ConfigMgr 2016"                    -Version "" -Publisher "" -Language "" -CommandLine "cscript.exe Configure-ExtendADforConfigMgr2016.wsf"             -WorkingDirectory ".\Applications\Configure - Extend AD for ConfigMgr 2016"                    -ApplicationSourcePath "$ScriptFolder\Applications\Configure - Extend AD for ConfigMgr 2016"                  -DestinationFolder "Configure - Extend AD for ConfigMgr 2016"                   -Verbose
    # Install ConfigMgr 2016
    Import-MDTApplication -path "$MDTpsDrive`:\Applications" -enable "True" -Name "Install - ConfigMgr 2016 1511"                               -ShortName "Install - ConfigMgr 2016 1511"                               -Version "" -Publisher "" -Language "" -CommandLine "cscript.exe Install-ConfigMgr2016.wsf"                          -WorkingDirectory ".\Applications\Install - ConfigMgr 2016 1511"                               -ApplicationSourcePath "$ScriptFolder\Applications\Install - ConfigMgr 2016 1511"                             -DestinationFolder "Install - ConfigMgr 2016 1511"                               -Verbose
    # Set AD Permissions
    Import-MDTApplication -path "$MDTpsDrive`:\Applications" -enable "True" -Name "Configure - Set AD permissions for ConfigMgr 2016"           -ShortName "Configure - Set AD permissions for ConfigMgr 2016"           -Version "" -Publisher "" -Language "" -CommandLine "cscript.exe Configure-SetADPermissionsForConfigMgr2016.wsf"     -WorkingDirectory ".\Applications\Configure - Set AD permissions for ConfigMgr 2016"           -ApplicationSourcePath "$ScriptFolder\Applications\Configure - Set AD permissions for ConfigMgr 2016"         -DestinationFolder "Configure - Set AD permissions for ConfigMgr 2016"           -Verbose
    # Install ADK 10
    Import-MDTApplication -path "$MDTpsDrive`:\Applications" -enable "True" -Name "Install - ADK 10"                                            -ShortName "Install - ADK 10"                                            -Version "" -Publisher "" -Language "" -CommandLine "cscript.exe Install-ADK.wsf"                                    -WorkingDirectory ".\Applications\Install - ADK 10"                                            -ApplicationSourcePath "$ScriptFolder\Applications\Install - ADK 10"                                          -DestinationFolder "Install - ADK 10"                                             -Verbose
# SQL 2014
    # Open Firewall Port
    Import-MDTApplication -path "$MDTpsDrive`:\Applications" -enable "True" -Name "Configure - Open Firewall for SQL Server 2014 Communication" -ShortName "Configure - Open Firewall for SQL Server 2014 Communication" -Version "" -Publisher "" -Language "" -CommandLine "cscript.exe Configure-OpenFirewallforSQL2014Communication.wsf" -WorkingDirectory ".\Applications\Configure - Open Firewall for SQL Server 2014 Communication" -ApplicationSourcePath "$ScriptFolder\Applications\Configure - Open Firewall for SQL Server 2014 Communication" -DestinationFolder "Configure - Open Firewall for SQL Server 2014 Communication" -Verbose
    # Install SQL 2014
    Import-MDTApplication -path "$MDTpsDrive`:\Applications" -enable "True" -Name "Install - SQL Server 2014 1.0"                               -ShortName "Install - SQL Server 2014"                                   -Version "" -Publisher "" -Language "" -CommandLine "cscript.exe Install-236.147.30.109.wsf"                               -WorkingDirectory ".\Applications\Install - SQL Server 2014"                                   -ApplicationSourcePath "$ScriptFolder\Applications\Install - SQL Server 2014"                                   -DestinationFolder "Install - SQL Server 2014"                                    -Verbose

   