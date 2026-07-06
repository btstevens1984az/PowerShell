#########################################################################################
#
# Date Built:        Feb. 6, 2018
# Function:          Install-LatestChrome
# 
# For help, please type "Get-Help InstallationDir\Install-LatestChrome.ps1
#
#########################################################################################

<# 
.SYNOPSIS 
    Downloads current chrome.msi automatically
    Copies both bit architecture Chrome.msi files and places them on your desktop
    Installs latest Chrome.msi per your bit-architecture (x86 - x64) 
    Cleans up your Download directory
    Creates a new Chrome-##-###.xml on the Core's F: drive in the proper location
.DESCRIPTION 
    This "ps1" file has 3 functions that need to run in order:
    1. Download-Chrome
    2. Install-Chrome
    3. Clean-Chromemsi
    4. Create-NewChromeXML
    All are bound together by the main function Install-LatestChrome
    File Name  : Install-LatestChrome.ps1
    Requires   : PowerShell V5 
.LINK 
    Chrome86.msi : http://dl.google.com/edgedl/chrome/install/GoogleChromeStandaloneEnterprise.msi 
    Chrome64.msi : http://dl.google.com/edgedl/chrome/install/GoogleChromeStandaloneEnterprise64.msi
.EXAMPLE 
   Install-LatestChrome
.RETURNVALUE 
   Exit Codes are collected after each step in this function.  Multiple pop-ups will occur to 
   let you know where you are at in the overall function.  I have disabled all Windows warning content
.ROLE  
   In order for this function to start, you must be a local administrator on your desktop
.PARAMETER
   Runs Silently in the background other than your informational messages
   There is a Variable which tells the function to install the correct 
   bit-architecture Chrome.msi file for whomever is running thi script, however 
   it downloads both Chrome.msi files
   Line 59:  $Installx64 = $True
.QUESTIONS
   You will be asked the following questions.  Please pay attention to SYNTAX
        What is the Chrome NAME .ex CHROME-64-140
        What is the Chrome TITLE .ex Google Chrome 64-140
        What is the Chrome DATE REVISED .ex 20180201
        What is the Chrome DATE POSTED .ex 20180201
        What is the Chrome SOFTWARE VERSION .ex 64.0.3282.140
        What is the Chrome PATCHURL .ex file://F:/ChromePatches/Chrome-64-140-x86.msi

#>

Function Install-LatestChrome {
{
 [cmdletbinding()]
 Param()
}

Function Download-Chrome {

    Write-Host "Downloading Google Chrome"
    #Obtaining the Current Chrome  Product Version to later differentiate
    $oldChromeVersioninfo = (Get-Item (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe")."(Default)").VersionInfo.ProductVersion
    Write-Host "Please allow several minutes for the install to complete"
    #Install Google Chrome x64 on 64-Bit systems? $True or $False
    $Installx64 = $false
    #Define the temporary location to cache the installer
    $DownloadDirectory = "\\$env:COMPUTERNAME\C$\Users\$env:USERNAME\Downloads"
    #Run the script silently, $True or $False
    $RunScriptSilent = $True
    #Set the system architecture as a value
    $OSArchitecture = (Get-WmiObject Win32_OperatingSystem).OSArchitecture
    #Exit if the script was not run with Administrator priveleges
    $User = New-Object Security.Principal.WindowsPrincipal( [Security.Principal.WindowsIdentity]::GetCurrent() )
    if (-not $User.IsInRole( [Security.Principal.WindowsBuiltInRole]::Administrator )) {
	Write-Host "Please run again with Administrator privileges"
    if ($RunScriptSilent -NE $True) {
    Write-Host "Just double-checking that you have local admin rights"
        }
    }
    #Test internet connection
    if (Test-Connection google.com -Count 3 -Quiet) {
	if ($OSArchitecture -eq "64-Bit" -and $Installx64 -eq $True) {
	$Link64 = "http://dl.google.com/edgedl/chrome/install/GoogleChromeStandaloneEnterprise64.msi"
	    } 
    Else
        {
    $Link86 = "http://dl.google.com/edgedl/chrome/install/GoogleChromeStandaloneEnterprise.msi"
    Start-Sleep -s 15
        if ($RunScriptSilent -NE $False) 
            {Write-Host "There was a problem with the download"}
        Else
            {Write-Host "Unable to connect to Googles servers"    
            ($RunScriptSilent -NE $True) 
            {Write-Host "Finishing up with the Chrome Download"}
        }
    }
	New-Item -ItemType Directory "$DownloadDirectory" -Force | Out-Null
	(New-Object System.Net.WebClient).DownloadFile($Link64, "$DownloadDirectory.\GoogleChromeStandaloneEnterprise64.msi")
    New-Item -ItemType Directory "$DownloadDirectory" -Force | Out-Null
    (New-Object System.Net.WebClient).DownloadFile($Link86, "$DownloadDirectory.\GoogleChromeStandaloneEnterprise.msi")
    Write-Host "The Chrome.msi installed correctly"
    }
} 
Download-Chrome
start-sleep -Seconds 10

Function Install-Chrome {

    Write-Host "Installing Chrome"
    #Unblock the .msi files so all child-items in the directory are unblocked
    $ChromeMSI64 = Get-Item -Path "\\$env:COMPUTERNAME\C$\Users\$env:USERNAME\Downloads\GoogleChromeStandaloneEnterprise64.msi" | Unblock-File
    $ChromeMSI86 = Get-Item -Path "\\$env:COMPUTERNAME\C$\Users\$env:USERNAME\Downloads\GoogleChromeStandaloneEnterprise.msi" | Unblock-File
    #Setting variables for directories
    $Chrome64Directory = "\\$env:COMPUTERNAME\C$\Users\$env:USERNAME\Desktop\Chrome64"
    $Chrome86Directory = "\\$env:COMPUTERNAME\C$\Users\$env:USERNAME\Desktop\Chrome86"
    #Copy-Item to the new directories
    Copy-Item -Path "\\$env:COMPUTERNAME\C$\Users\$env:USERNAME\Downloads\GoogleChromeStandaloneEnterprise64.msi" -Destination "\\232.110.116.228\share" -Force -Confirm:$false
    Copy-Item -Path "\\$env:COMPUTERNAME\C$\Users\$env:USERNAME\Downloads\GoogleChromeStandaloneEnterprise.msi" -Destination "\\232.110.116.228\share" -Force -Confirm:$false
    #Install Chrome
    $ChromeMSI64 = """$Chrome64Directory\Chrome64.msi"""
    $ChromeMSI86 = """$Chrome86Directory\Chrome86.msi"""
	$ExitCode64 = (Start-Process -filepath msiexec -argumentlist "/i $ChromeMSI64 /qn /norestart" -Wait -PassThru).ExitCode
    $ExitCode86 = (Start-Process -filepath msiexec -argumentlist "/i $ChromeMSI86 /qn /norestart" -Wait -PassThru).ExitCode
    
    #Grabbing versioninfo from the new Chrome.exe
    $NewChromeVersioninfo = (Get-Item (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe")."(Default)").VersionInfo.ProductVersion
    
    if ($ExitCode64,$Exitcode86 -eq 0 -or 1619) 
        {Write-Host "Your Chrome version has successfully been upgraded to $NewChromeVersioninfo"} 
        else
            {Write-Host "There was a problem installing Google Chrome. The Chrome.msi returned exit code`n Chrome64 Exit code = $ExitCode64 `n Chrome86 Exit Code = $ExitCode86."
        if ($RunScriptSilent -NE $True) 
            {Write-Host "Finishing up with the Chrome Install"}
    }
} 
Install-Chrome
start-sleep -Seconds 20

Function Clean-ChromeMSI {

        Write-Host "Removing Chrome installer"
        $DownloadDirectory = "$env:COMPUTERNAME\C$\Users\$env:USERNAME\Downloads"
        # Remove the installer
        Remove-Item "\\$env:COMPUTERNAME\C$\Users\$env:USERNAME\Downloads\GoogleChromeStandaloneEnterprise64.msi" -Confirm:$false -ErrorAction Stop
        Remove-Item "\\$env:COMPUTERNAME\C$\Users\$env:USERNAME\Downloads\GoogleChromeStandaloneEnterprise.msi" -Confirm:$false -ErrorAction Stop
        Write-Host "The Chrome.msi files have been removed from your downloads directory"
        Write-Host "`nChrome installation complete!`nThe old chrome version was $oldChromeVersioninfo `nThe new chrome version is $NewChromeVersioninfo `nAll finished `nGood-bye"
        
}
Clean-ChromeMSI

[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null

Function Create-NewChromeXML {

$ButtonType = [System.Windows.MessageBoxButton]::OK
$MessageboxTitle = “Warning”
$Messageboxbody = “Be cautious when executing this script as `n it handles files directly on the Radia Core.`n `n `nDo you want to continue?”
$MessageIcon = [System.Windows.MessageBoxImage]::Warning
[System.Windows.MessageBox]::Show($Messageboxbody,$MessageboxTitle,$ButtonType,$messageicon)

#To automate this whole script:
$ChromeName = [Microsoft.VisualBasic.Interaction]::InputBox("What is the Chrome NAME? `n Use the example syntax in the textbox","Chrome Name","CHROME-64-140".Trim())
$ChromeTitle = [Microsoft.VisualBasic.Interaction]::InputBox("What is the Chrome TITLE? `n Use the example syntax in the textbox","Chrome Title","Google Chrome 64-140".Trim())
$DateRevised = [Microsoft.VisualBasic.Interaction]::InputBox("What is the Chrome DATE REVISED? `n Use the example syntax in the textbox","Date Revised","20180201".Trim())
$DatePosted = [Microsoft.VisualBasic.Interaction]::InputBox("What is the Chrome DATE POSTED? `n Use the example syntax in the textbox","Date Posted","20180201".Trim())
$SoftwareVersion = [Microsoft.VisualBasic.Interaction]::InputBox("What is the Chrome SOFTWARE VERSION? `n Use the example syntax in the textbox","Software Version","64.0.3282.140".Trim())
$PatchURL =  "file://F:/ChromePatches/$ChromeName.msi".Trim()
    
#Gets the .xml file and pastes a new one to the directory
Get-Item -Path "\\75.87.199.36\f$\PSL\RCA\Data\PatchManager\patch\custom\CHROME-64-140.xml" |
Copy-Item -Destination "\\75.87.199.36\f$\PSL\RCA\Data\PatchManager\patch\custom\$ChromeName.xml"

#Work with .xml file
$fileChromeName = “\\75.87.199.36\f$\PSL\RCA\Data\PatchManager\patch\custom\$ChromeName.xml"
$XmlChrome = [System.Xml.XmlDocument](Get-Content $fileChromeName)
$path = "\\75.87.199.36\f$\PSL\RCA\Data\PatchManager\patch\custom\$ChromeName.xml"

#Make necessary changes to Chrome-##-###.xml
$XMLCustomDirectory = Get-Content "\\75.87.199.36\F$\PSL\RCA\Data\PatchManager\patch\custom\$ChromeName.xml"
$Messageboxbody1 = "Your '$ChromeName.xml' file has been saved and created on the core's patch custom directory.`nThe file will automatically open for you now''"
$XmlChrome.Bulletin.Name="$ChromeName"
$XmlChrome.Bulletin.Title="$ChromeTitle"
$XmlChrome.Bulletin.DateRevised="$DateRevised"
$XmlChrome.Bulletin.DatePosted="$DatePosted"
$xmlChangeChromeVersion = $XmlChrome.SelectNodes("./Bulletin/Products/Product/Releases/Release/Patch/PatchSignature/FileChg")
$xmlChangeChromeVersion.SetAttribute("Version", "$SoftwareVersion")
$xmlChangePatchURL = $XmlChrome.SelectNodes("./Bulletin/Products/Product/Releases/Release/Patch")
$xmlChangePatchURL.SetAttribute("PatchURL", "$PatchURL")

#Save the .xml
$XmlChrome.Save($fileChromeName);

#The script is finished
Invoke-Item -Path $fileChromeName
}
Create-NewChromeXML
Start-Sleep -Seconds 10
<#

#Below are the attributes for each element
#$XmlChrome Element
$XmlChrome

Bulletin
--------
Bulletin

#$XmlChrome.Bulletin Element
$XmlChrome.Bulletin

PopularitySeverityID : 0
Rollback             : N
Type                 : Security
URL                  : https://www.google.com/intl/en/chrome/browser/welcome.html
FAQURL               : https://www.google.com/intl/en/chrome/browser/welcome.html
MitigationSeverityID : 0
Vendor               : Microsoft
Supported            : Yes
ImpactSeverityID     : 0
SchemaVersion        : 1.0
PreReqSeverityID     : 0
CVEName              :
DateRevised          : 20180201
Source               : custom
Name                 : CHROME-64-140
Title                : Google Chrome 64-140
DatePosted           : 20180201
Platform             : winnt
Products             : Products

#$XmlChrome.Bulletin.Products Element
$XmlChrome.Bulletin.Products

{Windows 7 (MU), Windows 10 (MU)}

#$XmlChrome.Bulletin.Products.Product Element
$XmlChrome.Bulletin.Products.Product

Name            FixedInRelease Tag                                  Releases
----            -------------- ---                                  --------
Windows 7 (MU)  0              bfe5b177-a086-47a0-b102-097e4fa1f807 Releases
Windows 10 (MU) 0              A3C2375D-0C8A-42F9-BCE0-28333E198407 Releases

 

#$XmlChrome.Bulletin.Products.Product.Releases Element
$XmlChrome.Bulletin.Products.Product.Releases
Release
-------
Release

#$XmlChrome.Bulletin.Products.Product.Releases.Release Element
$XmlChrome.Bulletin.Products.Product.Releases.Release

Name            Tag                                  Patch        
----            ---                                  -----        
Windows 7 (MU)  bfe5b177-a086-47a0-b102-097e4fa1f807 {Patch, Patch}
Windows 10 (MU) A3C2375D-0C8A-42F9-BCE0-28333E198407 {Patch, Patch}

#$XmlChrome.Bulletin.Products.Product.Releases.Release.Patch Element
$XmlChrome.Bulletin.Products.Product.Releases.Release.Patch

Rollback             : Y
VerifyCmdline        :
PatchURL             : file://F:/ChromePatches/Chrome-64-140-x86.msi
Architecture         : x86
Reboot               : N
InstallCmdline       : /qn
Language             : en
MSSUSName            :
SupercededByBulletin :
SupercededByMSPatch  :
OSVersion            :
PatchFileName        :
ObjectType           : msipatch
ProbeCmdline         :
Superceded           :
Platform             : winnt
UninstallCmdline     :
Extract              :
Rating               : Moderate
SHA                  :
ZRSCSIZE             :
ISODATE              :
PatchSignature       : PatchSignature

Rollback             : Y
VerifyCmdline        :
PatchURL             : file://F:/ChromePatches/Chrome-64-140-x64.msi
Architecture         : amd64
Reboot               : N
InstallCmdline       : /qn
Language             : en
MSSUSName            :
SupercededByBulletin :
SupercededByMSPatch  :
OSVersion            :
PatchFileName        :
ObjectType           : msipatch
ProbeCmdline         :
Superceded           :
Platform             : winnt
UninstallCmdline     :
Extract              :
Rating               : Moderate
SHA                  :
ZRSCSIZE             :
ISODATE              :
PatchSignature       : PatchSignature

Rollback             : Y
VerifyCmdline        :
PatchURL             : file://F:/ChromePatches/Chrome-64-140-x86.msi
Architecture         : x86
Reboot               : N
InstallCmdline       : /qn
Language             : en
MSSUSName            :
SupercededByBulletin :
SupercededByMSPatch  :
OSVersion            :
PatchFileName        :
ObjectType           : msipatch
ProbeCmdline         :
Superceded           :
Platform             : winnt
UninstallCmdline     :
Extract              :
Rating               : Moderate
SHA                  :
ZRSCSIZE             :
ISODATE              :
PatchSignature       : PatchSignature

Rollback             : Y
VerifyCmdline        :
PatchURL             : file://F:/ChromePatches/Chrome-64-140-x64.msi
Architecture         : amd64
Reboot               : N
InstallCmdline       : /qn
Language             : en
MSSUSName            :
SupercededByBulletin :
SupercededByMSPatch  :
OSVersion            :
PatchFileName        :
ObjectType           : msipatch
ProbeCmdline         :
Superceded           :
Platform             : winnt
UninstallCmdline     :
Extract              :
Rating               : Moderate
SHA                  :
ZRSCSIZE             :
ISODATE              :
PatchSignature       : PatchSignature

 

#$XmlChrome.Bulletin.Products.Product.Releases.Release.Patch.PatchSignature Element
$XmlChrome.Bulletin.Products.Product.Releases.Release.Patch.PatchSignature

FileChg
-------
FileChg
FileChg
FileChg
FileChg

#$XmlChrome.Bulletin.Products.Product.Releases.Release.Patch.PatchSignature.FileChg Element
$XmlChrome.Bulletin.Products.Product.Releases.Release.Patch.PatchSignature.FileChg

Name            : chrome.exe
CRC32           :
Gmttime         :
Path            : %programfiles%\Google\Chrome\Application
Size            :
Checksum        :
Gmtdate         :
DesiredState    : !E=8,EQ=0,GT=0,LT=8
ReportThreshold : 1
Use             : VERSION
 
Name            : chrome.exe
CRC32           :
Gmttime         :
Path            : %programfiles(x86)%\Google\Chrome\Application
Size            :
Checksum        :
Gmtdate         :
DesiredState    : !E=8,EQ=0,GT=0,LT=8
ReportThreshold : 1
Use             : VERSION
 

Name            : chrome.exe
CRC32           :
Gmttime         :
Path            : %programfiles%\Google\Chrome\Application
Size            :
Checksum        :
Gmtdate         :
DesiredState    : !E=8,EQ=0,GT=0,LT=8
ReportThreshold : 1
Use             : VERSION

Name            : chrome.exe
CRC32           :
Gmttime         :
Path            : %programfiles(x86)%\Google\Chrome\Application
Size            :
Checksum        :
Gmtdate         :
DesiredState    : !E=8,EQ=0,GT=0,LT=8
ReportThreshold : 1
Use             : VERSION

#$XmlChrome.Bulletin.Products.Product.Releases.Release.Patch.PatchSignature.FileChg.Version Element
$XmlChrome.Bulletin.Products.Product.Releases.Release.Patch.PatchSignature.FileChg.Version

64.0.3282.140
64.0.3282.140
64.0.3282.140
64.0.3282.140

#>
}