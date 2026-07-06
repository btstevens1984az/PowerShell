# Purpose: Uninstall windows10 bloatware — Windows desktop configuration and management.
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))  
{  
  $arguments = "& '" +$myinvocation.mycommand.definition + "'"
  Start-Process powershell -Verb runAs -ArgumentList $arguments
  Break
}
mkdir c:\temp\
mkdir c:\temp\scriptdownloads
Clear-Host

$AppList = "Microsoft.SkypeApp",          
           "Microsoft.ZuneMusic",
           "Microsoft.ZuneVideo",
           "Microsoft.Office.OneNote",
           "Microsoft.BingFinance",
           "Microsoft.BingNews",
           "Microsoft.BingWeather",
           "Microsoft.BingSports",
           "Microsoft.MicrosoftOfficeHub",
		   "Microsoft.Wallet",
		   "Microsoft.OneConnect",
		   "Microsoft.MSPaint",
		   "Microsoft.Print3D",
		   "Microsoft.Messaging",
		   "Microsoft.Microsoft3DViewer",
		   "Microsoft.Windows.Cortana",
		   "Microsoft.3DBuilder",
		   "Microsoft.WindowsAlarms",
		   "Microsoft.windowscommunicationsapps",
		   "Microsoft.Getstarted",
		   "Microsoft.WindowsMaps",
		   "Microsoft.MicrosoftSolitaireCollection",
		   "Microsoft.WindowsFeedbackHub",
		   "Microsoft.MixedReality.Portal",
		   "Microsoft.GetHelp",
		   "Microsoft.People",
		   "Microsoft.549981C3F5F10",
		   "Microsoft.549981cf5f10",
		   "SpotifyAB.SpotifyMusic",
		   "king.com.BubbleWitch3Saga",
		   "A278AB0D.DisneyMagicKingdoms",
		   "A278AB0D.MarchofEmpires",
		   "king.com.CandyCrushSodaSaga",
		   "SpotifyAB.SpotifyMusic",
		   "4DF9E0F8.Netflix",
		   "C27EB4BA.DropboxOEM",
		   "Amazon.com.Amazon",
		   "7EE7776C.LinkedInforWindows",
		   "PricelinePartnerNetwork.Booking.comEMEABigsavingso",
		   "Microsoft.BingTranslator",
		   "MixedRealityLearning"
		   "9E2F88E3.Twitter_wgeqdkkx372wm"
		   "Microsoft.BingTranslator",
		   "PricelinePartnerNetwork.Booking.comEMEABigsavingso"
		   "Facebook.InstagramBeta"
		   
#
$RemoveXboxAppList = "Microsoft.Xbox.TCUI",
		   "Microsoft.XboxSpeechToTextOverlay",
		   "Microsoft.XboxApp",
		   "Microsoft.XboxGameOverlay",
		   "Microsoft.XboxGamingOverlay"
#
Clear-Host
Write-Output " ____  __    _____    __   ____  _    _    __    ____  ____    ____  ____  __  __  _____  _  _  __    __   
(  _ \(  )  (  _  )  /__\ (_  _)( \/\/ )  /__\  (  _ \( ___)  (  _ \( ___)(  \/  )(  _  )( \/ )/__\  (  )  
 ) _ ( )(__  )(_)(  /(__)\  )(   )    (  /(__)\  )   / )__)    )   / )__)  )    (  )(_)(  \  //(__)\  )(__ 
(____/(____)(_____)(__)(__)(__) (__/\__)(__)(__)(_)\_)(____)  (_)\_)(____)(_/\/\_)(_____)  \/(__)(__)(____)"
""

function start-main-menu { 
$OriginalPref = $ProgressPreference # Default is 'Continue'
$ProgressPreference = "SilentlyContinue"

do { $myInput = (Read-Host 'Would you like to uninstall Windows10 Bloatware?(Y/N)').ToLower() } while ($myInput -notin @('y','n'))
if ($myInput -eq 'y') {
#############################################
""
 do { $myInput = (Read-Host 'Would you like to apply this for all users or just the currently logged on user?(all/user)').ToLower() } while ($myInput -notin @('all','user'))
 if ($myInput -eq 'all') {
""
     do { $myInput = (Read-Host 'Would you like to remove Xbox applications as well?(Y/N)').ToLower() } while ($myInput -notin @('Y','N'))
     if ($myInput -eq 'y') {
     start-allusers-bloatware-noxbox
     start-basic-bloatware-remover
	 Clear-Host
	 Write-Output "Complete."
	 pause
	 $ProgressPreference = $OriginalPref
     exit
	 }
	 if ($myinput -eq 'n') {
	 start-allusers-bloatware
	 start-basic-bloatware-remover
	 Clear-Host
	 Write-Output "Complete."
	 pause
	 $ProgressPreference = $OriginalPref
	 exit
	 }
}}
##############################################
 if ($myinput -eq 'user') {
""
Write-Output "Enter the user context credentials."
$cred = Get-Credential
Invoke-WebRequest https://github.com/Ray-MRQ/MRQ/raw/master/Scripts/Uninstall_windows10_bloatware_user.ps1 -outfile c:\temp\scriptdownloads\windows10bloatware_user_specfic.ps1
Start-Process -FilePath Powershell -Credential $cred -ArgumentList '-File', c:\temp\scriptdownloads\windows10bloatware_user_specfic.ps1
pause
Remove-Item c:\temp\scriptdownloads\windows10bloatware_user_specfic.ps1 -force > $null 2>&1
exit
}
else { 
""
Write-Output "Not removing bloatware..."
pause
exit
}}

function start-allusers-bloatware-noxbox {

ForEach ($App in $AppList)
{
$PackageFullName = (Get-AppxPackage $App -allusers).PackageFullName
$ProPackageFullName = (Get-AppxProvisionedPackage -online | Where-Object {$_.Displayname -eq $App}).PackageName
if ($PackageFullName)
{
Write-Host "Removing Package: $App"
remove-AppxPackage -package $PackageFullName 
}
if ($ProPackageFullName)
{
Write-Host "Removing Provisioned Package: $ProPackageFullName"
Remove-AppxProvisionedPackage -online -packagename $ProPackageFullName -allusers
}
}
#######################################################################
ForEach ($App in $RemoveXboxAppList)
{
$PackageFullName = (Get-AppxPackage $App -allusers).PackageFullName
$ProPackageFullName = (Get-AppxProvisionedPackage -online | Where-Object {$_.Displayname -eq $App}).PackageName
if ($PackageFullName)
{
Write-Host "Removing Package: $App"
remove-AppxPackage -package $PackageFullName 
}
if ($ProPackageFullName)
{
Write-Host "Removing Provisioned Package: $ProPackageFullName"
Remove-AppxProvisionedPackage -online -packagename $ProPackageFullName -allusers
}
}
Write-Output "Completed."
}

function start-allusers-bloatware {

ForEach ($App in $AppList)
{
$PackageFullName = (Get-AppxPackage $App -allusers).PackageFullName
$ProPackageFullName = (Get-AppxProvisionedPackage -online | Where-Object {$_.Displayname -eq $App}).PackageName
if ($PackageFullName)
{
Write-Host "Removing Package: $App"
remove-AppxPackage -package $PackageFullName 
}
if ($ProPackageFullName)
{
Write-Host "Removing Provisioned Package: $ProPackageFullName"
Remove-AppxProvisionedPackage -online -packagename $ProPackageFullName -allusers
}
}
Write-Output "Completed."
}

function start-basic-bloatware-remover {
     #Stops Cortana from being used as part of your Windows Search Function
    $Search = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
    If (Test-Path $Search) {
        Set-ItemProperty $Search AllowCortana -Value 0 
    }
    #Disables Web Search in Start Menu
    $WebSearch = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
    Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" BingSearchEnabled -Value 0 
    If (!(Test-Path $WebSearch)) {
        New-Item $WebSearch
    }
    Set-ItemProperty $WebSearch DisableWebSearch -Value 1 
""
Invoke-Command {reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" /f}
Invoke-Command {reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" /f}
Invoke-Command {reg add HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Explorer\ /v DisableSearchBoxSuggestions /t reg_dword /d 1 /f}
Invoke-Command {reg add HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v ShowTaskViewButton /t reg_dword /d 0 /f}
Invoke-Command {reg add HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Search /v SearchboxTaskbarMode /t red_dword /d 0 /f}
Invoke-Command {reg add HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Explore /v HidePeopleBar /t reg_dword /d 1 /f}
Remove-Item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\LastPass.lnk" -force
Remove-Item "C:\Program Files (x86)\Online Services\LastPass" -recurse -force > $null 2>&1 
""
Clear-Host
Write-Output "Refreshed screen to apply."
Write-Output "Completed."
Stop-Process -name explorer -Force
}

start-main-menu