# Purpose: Uninstall windows10 bloatware user — Windows desktop configuration and management.
$OriginalPref = $ProgressPreference # Default is 'Continue'
$ProgressPreference = "SilentlyContinue"
Write-Output " ____  __    _____    __   ____  _    _    __    ____  ____    ____  ____  __  __  _____  _  _  __    __   
(  _ \(  )  (  _  )  /__\ (_  _)( \/\/ )  /__\  (  _ \( ___)  (  _ \( ___)(  \/  )(  _  )( \/ )/__\  (  )  
 ) _ ( )(__  )(_)(  /(__)\  )(   )    (  /(__)\  )   / )__)    )   / )__)  )    (  )(_)(  \  //(__)\  )(__ 
(____/(____)(_____)(__)(__)(__) (__/\__)(__)(__)(_)\_)(____)  (_)\_)(____)(_/\/\_)(_____)  \/(__)(__)(____)"
Write-Output ''
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
		   "MixedRealityLearning",
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
#

function start-main-menu{
	do { $myInput = (Read-Host 'Would you like to remove Xbox applications as well?(Y/N)').ToLower() } while ($myInput -notin @('Y','N'))
    if ($myInput -eq 'y') {
	start-user-bloatware-noxbox
	start-basic-bloatware-remover
	Clear-Host
	Write-Output "Completed bloatware removal. Please continue."
	pause
	$ProgressPreference = $OriginalPref
	exit
	}
	if ($myinput -eq 'n') {
	start-user-bloatware
	start-basic-bloatware-remover
	Clear-Host
	Write-Output "Completed bloatware removal. Please continue."
	pause
	$ProgressPreference = $OriginalPref
	exit
}}

function start-user-bloatware {
ForEach ($App in $AppList)
{
$PackageFullName = (Get-AppxPackage $App).PackageFullName
if ($PackageFullName)
{
Write-Host "Removing Package: $App"
remove-AppxPackage -package $PackageFullName 
}
}
Clear-Host
Write-Output ''
Write-Output "Complete."
Write-Output ''
}

function start-user-bloatware-noxbox {
ForEach ($App in $AppList)
{
$PackageFullName = (Get-AppxPackage $App).PackageFullName
if ($PackageFullName)
{
Write-Host "Removing Package: $App"
remove-AppxPackage -package $PackageFullName 
}
}
#############################################################################
ForEach ($App in $RemoveXboxAppList)
{
$PackageFullName = (Get-AppxPackage $App).PackageFullName
if ($PackageFullName)
{
Write-Host "Removing Package: $App"
remove-AppxPackage -package $PackageFullName 
}
}
Clear-Host
Write-Output ''
Write-Output "Complete."
Write-Output ''
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
Write-Output ''
Invoke-Command {reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" /f}
Invoke-Command {reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" /f}
Invoke-Command {reg add HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Explorer\ /v DisableSearchBoxSuggestions /t reg_dword /d 1 /f}
Invoke-Command {reg add HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v ShowTaskViewButton /t reg_dword /d 0 /f}
Invoke-Command {reg add HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Search /v SearchboxTaskbarMode /t red_dword /d 0 /f}
Invoke-Command {reg add HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Explore /v HidePeopleBar /t reg_dword /d 1 /f}
Write-Output ''
Clear-Host
Write-Output "Refreshed screen to apply."
Write-Output "Completed."
Stop-Process -name explorer -Force
}

start-main-menu