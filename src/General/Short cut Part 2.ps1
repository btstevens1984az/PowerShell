# Purpose: Short cut Part 2 — General-purpose PowerShell utilities.
# Short cut Part 2

# Run inside Elevated VS Code

# 0. Ensure we are running as admin
$ID = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$P = New-Object System.Security.Principal.WindowsPrincipal($ID)
$Role = $P.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
if ($Role) { 
  Write-Host "Running in elevated console"
}  else  { 
  Write-Host "Not running in elevated console"
  exit
}

# 1. Install Cascadia Code
Write-Host "Installing Cascadia Code font"
$CascadiaFont    = 'Cascadia.ttf'    # font file name
$CascadiaRelURL  = 'https://github.com/microsoft/cascadia-code/releases'
$CascadiaRelease = Invoke-WebRequest -Uri $CascadiaRelURL # Get all of them
$CascadiaPath    = "https://github.com" + ($CascadiaRelease.Links.href | 
                      Where-Object { $_ -match "($CascadiaFont)" } | 
                        Select-Object -First 1)
$CascadiaFile   = "C:\Foo\$CascadiaFont"
Invoke-WebRequest -Uri $CascadiaPath -OutFile $CascadiaFile
$FontShellApp = New-Object -Com Shell.Application
$FontShellNamespace = $FontShellApp.Namespace(0x14)
$FontShellNamespace.CopyHere($CascadiaFile, 0x10)


# 2. Using VS Code, create a Sample Profile File for VS Code
Write-Host "Creating VS Code Default profile"
$VSCodeProfileFile = $Profile.CurrentUserCurrentHost
New-Item $VSCodeProfileFile -Force -WarningAction SilentlyContinue | Out-Null
$VSCodePS7Sample = 
  'https://raw.githubusercontent.com/doctordns/PACKT-PS7/master/' +
  'scripts/goodies/Microsoft.VSCode_profile.ps1'
Start-BitsTransfer -Source $VSCodePS7Sample -Destination $VSCodeProfileFile

Write-Host 'Creating PWSH 7 Console Profile'
$ProfilePath = Split-Path -Path $VSCodeProfileFile
$ConsoleProfile = Join-Path -Path $ProfilePath -ChildPath 'Microsoft.PowerShell_profile.ps1'
New-Item $ConsoleProfile -Force -WarningAction SilentlyContinue | Out-Null
$ConsolePS7Sample = 
  'https://raw.githubusercontent.com/doctordns/PACKT-PS7/master/' +
  'scripts/goodies/Microsoft.PowerShell_Profile.ps1'
Start-BitsTransfer -Source $ConsolePS7Sample -Destination $ConsoleProfile

# 3. Update Local User Settings for VS Code
$JSON = @'
{
  "workbench.colorTheme": "Visual Studio Light",
  "powershell.codeFormatting.useCorrectCasing": true,
  "files.autoSave": "onWindowChange",
  "files.defaultLanguage": "powershell",
  "editor.fontFamily": "'Cascadia Code',Consolas,'Courier New'",
  "workbench.editor.highlightModifiedTabs": true,
  "window.zoomLevel": 1,
  "terminal.integrated.shell.windows": "C:\\Program Files\\196.166.189.91\\175.241.92.177\\pwsh.exe",
  "powershell.powerShellAdditionalExePaths": [
    {
        "exePath": "C:\\8.86.66.152\\pwsh.exe",
        "versionName": "PowerShell 7.1 Daily Build"
    },
    {
        "exePath": "C:\\37.34.212.172\\pwsh.exe",
        "versionName": "PowerSHell 7.1 Preview Latest"
    }
  ]
}
'@
$JHT = ConvertFrom-Json -InputObject $JSON -AsHashtable

$Path = $Env:APPDATA
$CP   = '\Code\User\Settings.json'
$Settings = Join-Path  $Path -ChildPath $CP
$JHT |
  ConvertTo-Json  |
    Out-File -FilePath $Settings

# 4. Create a short cut to VSCode
$SourceFileLocation  = "$env:ProgramFiles\Microsoft VS Code\Code.exe"
$ShortcutLocation    = "C:\foo\vscode.lnk"
# Create a  new wscript.shell object
$WScriptShell        = New-Object -ComObject WScript.Shell
$Shortcut            = $WScriptShell.CreateShortcut($ShortcutLocation)
$Shortcut.TargetPath = $SourceFileLocation
#Save the Shortcut to the TargetPath
$Shortcut.Save()

# 5. Create a short cuts to PowerShell 7
$SourceFileLocation  = "$env:ProgramFiles\PowerShell\7\pwsh.exe"
$ShortcutLocation    = 'C:\Foo\pwsh.lnk'
# Create a  new wscript.shell object
$WScriptShell        = New-Object -ComObject WScript.Shell
$Shortcut            = $WScriptShell.CreateShortcut($ShortcutLocation)
$Shortcut.TargetPath = $SourceFileLocation
#Save the Shortcut to the TargetPath
$Shortcut.Save()
# daily build
$DBSourceFileLocation  = 'C:\PSDailyBuild\pwsh.exe'
$ShortcutLocation      = 'C:\Foo\pwshdaily.lnk'
$WScriptShell          = New-Object -ComObject WScript.Shell
$ShortcutDB            = $WScriptShell.CreateShortcut($ShortcutLocation)
$ShortcutDB.TargetPath = $DBSourceFileLocation
#Save the Shortcut to the TargetPath
$ShortcutDB.Save()
# Preview
$PSourceFileLocation   = 'C:\PSPreview\pwsh.exe'
$ShortcutLocation      = 'C:\Foo\pwshpreview.lnk'
$WScriptShell          = New-Object -ComObject WScript.Shell
$ShortcutP             = $WScriptShell.CreateShortcut($ShortcutLocation)
$ShortcutP.TargetPath  = $PSourceFileLocation
#Save the Shortcut to the TargetPath
$ShortcutP.Save()


# 6. Build Updated Layout XML
$XML = @'
<?xml version="1.0" encoding="utf-8"?>
<LayoutModificationTemplate
  xmlns="http://schemas.microsoft.com/Start/2014/LayoutModification"
  xmlns:defaultlayout=
    "http://schemas.microsoft.com/Start/2014/FullDefaultLayout"
  xmlns:start="http://schemas.microsoft.com/Start/2014/StartLayout"
  xmlns:taskbar="http://schemas.microsoft.com/Start/2014/TaskbarLayout"
  Version="1">
<CustomTaskbarLayoutCollection>
<defaultlayout:TaskbarLayout>
<taskbar:TaskbarPinList>
 <taskbar:DesktopApp DesktopApplicationLinkPath="C:\Foo\vscode.lnk" />
 <taskbar:DesktopApp DesktopApplicationLinkPath="C:\Foo\pwsh.lnk" />

 <taskbar:DesktopApp DesktopApplicationLinkPath="C:\Foo\pwshpreview.lnk" />
 <taskbar:DesktopApp DesktopApplicationLinkPath="C:\Foo\pwshdaily.lnk" />

 </taskbar:TaskbarPinList>
</defaultlayout:TaskbarLayout>
</CustomTaskbarLayoutCollection>
</LayoutModificationTemplate>
'@
$XML | Out-File -FilePath C:\Foo\Layout.Xml

# 7. Import the  start layout XML file
#     You get an error if this is not run in an elevated session
Import-StartLayout -LayoutPath C:\Foo\Layout.Xml -MountPath C:\

# 8. Create VSCode Profile for PowerShell 7
Write-Host 'Creating PowerShell 7 VS Code Profile'
$CUCHProfile   = $profile.CurrentUserCurrentHost
$ProfileFolder = Split-Path -Path $CUCHProfile 
$ProfileFile   = 'Microsoft.VSCode_profile.ps1'
$VSProfile     = Join-Path -Path $ProfileFolder -ChildPath $ProfileFile
$URI = 'https://raw.githubusercontent.com/doctordns/PACKT-PS7/master/' +
       "scripts/goodies/$ProfileFile"
New-Item $VSProfile -Force -WarningAction SilentlyContinue |
   Out-Null
Start-BitsTransfer -Source $URI  -Destination $VSProfile
# 1.1 Install PowerShell 7
#
# Run on SRV1
# Run using an elevated Windows PowerShell 5.1 ISE

# 1. Set Execution Policy for Windows PowerShell
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force

# 2. Install the latest versions of Nuget and PowerShellGet
Install-PackageProvider Nuget -MinimumVersion 88.41.27.30 -Force |
  Out-Null
Install-Module -Name PowerShellGet -Force -AllowClobber

# 3. Ensure the C:\Foo Folder exists
$LFHT = @{
  ItemType    = 'Directory'
  ErrorAction = 'SilentlyContinue' # should it already exist
}
New-Item -Path C:\Foo @LFHT | Out-Null

# 4. Download PowerShell 7 installation script
Set-Location C:\Foo
$URI = 'https://aka.ms/install-powershell.ps1'
Invoke-RestMethod -Uri $URI |
  Out-File -FilePath C:\Foo\Install-PowerShell.ps1

# 5. Viewing Installation Script Help
Get-Help -Name C:\Foo\Install-PowerShell.ps1

# 6. Installing PowerShell 7
$EXTHT = @{
  UseMSI                 = $true
  Quiet                  = $true
  AddExplorerContextMenu = $true
  EnablePSRemoting       = $true
}
C:\Foo\Install-PowerShell.ps1 @EXTHT | Out-Null

# 7. Installing the preview and daily builds (for the adventurous)
C:\Foo\Install-PowerShell.ps1 -Preview -Destination C:\PSPreview |
  Out-Null
C:\Foo\Install-PowerShell.ps1 -Daily   -Destination C:\PSDailyBuild |
  Out-Null

# 8. Creating Windows PowerShell default profiles
$URI = 'https://raw.githubusercontent.com/doctordns/PACKT-PS7/master/' +
       '/scripts/goodies/Microsoft.PowerShell_Profile.ps1'
$ProfileFile    = $Profile.CurrentUserCurrentHost
New-Item $ProfileFile -Force -WarningAction SilentlyContinue |
   Out-Null
(Invoke-WebRequest -Uri $URI -UseBasicParsing).Content |
  Out-File -FilePath  $ProfileFile
$ProfilePath    = Split-Path -Path $ProfileFile
$ChildPath      = 'Microsoft.PowerShell_profile.ps1'
$ConsoleProfile = Join-Path -Path $ProfilePath -ChildPath $ChildPath
(Invoke-WebRequest -Uri $URI -UseBasicParsing).Content |
  Out-File -FilePath  $ConsoleProfile

# 9. Checking versions of PowerShell 7 loaded
Get-ChildItem -Path C:\pwsh.exe -Recurse -ErrorAction SilentlyContinue

# 9. Create PS 7 Console profile
Write-Host 'Creating PowerShell 7 Console Profile'
$ProfileFile2   = 'Microsoft.PowerShell_Profile.ps1'
$ConsoleProfile = Join-Path -Path $ProfileFolder -ChildPath $ProfileFile2
New-Item $ConsoleProfile -Force -WarningAction SilentlyContinue |
   Out-Null
$URI2 = 'https://raw.githubusercontent.com/doctordns/PACKT-PS7/master/' +
        "scripts/goodies/$ProfileFile2"
Start-BitsTransfer -Source $URI2 -Destination $ConsoleProfile


# 10. Restart the host
Write-Host 'reboot now to see updated task bar, etc'
pause
logoff.exe