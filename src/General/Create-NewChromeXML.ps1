#--------------------------------------------------------------------------------------
#
#  Date created:    02/05/2018
#  File Version:    v1.0.0
#
#--------------------------------------------------------------------------------------
 
<#

  .SYNOPSIS  
    Creates a new Chrome-##-###.xml on the Core's F: drive in the proper location
  .EXAMPLE 
   Create-NewChromeXML
  .QUESTIONS
   You will be asked the following questions.  Please pay attention to SYNTAX
        What is the Chrome NAME .ex CHROME-64-140
        What is the Chrome TITLE .ex Google Chrome 64-140
        What is the Chrome DATE REVISED .ex 20180201
        What is the Chrome DATE POSTED .ex 20180201
        What is the Chrome SOFTWARE VERSION .ex 64.0.3282.140
        What is the Chrome PATCHURL .ex file://F:/ChromePatches/Chrome-64-140-x86.msi

#>

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

