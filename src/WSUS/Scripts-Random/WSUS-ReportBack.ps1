# Purpose: 210.252.8.204-ReportBack — Windows Server Update Services administration.
#   James Wylde


#----------------------------------------------------------------------------------------#
#   Standard

net stop wuauserv & net stop bits & net stop cryptsvc & cd %systemroot% & ren SoftwareDistribution SoftwareDistribution[OLD] & cd %systemroot%\system32 & ren catroot2 catroot2[OLD]

net start wuauserv & net start bits & net start cryptsvc & wuauclt.exe


#----------------------------------------------------------------------------------------#
#   Get if back in 31.39.1.252

$computers = get-content C:\Users\a1-wyldeja\Desktop\190.190.53.202.txt

foreach ($computer in $computers){

get-wsuscomputer -NameIncludes $computer -ErrorAction stop}

#----------------------------------------------------------------------------------------#
#   Kill Software Distribution empties

net stop wuauserv
rd /s /q %systemroot%\SoftwareDistribution
net start wuauserv

#----------------------------------------------------------------------------------------#
#   Stop/Start services

net stop bits
net stop wuauserv
net stop cryptsvc 

sleep -s 5

net start bits
net start wuauserv
net stop cryptsvc

#----------------------------------------------------------------------------------------#
#   Kill qmgr database

Del "%ALLUSERSPROFILE%\Application Data\Microsoft\Network\Downloader\qmgr*.dat"

Del C:\ProgramData\Microsoft\Network\Downloader\qmgr*.dat

#----------------------------------------------------------------------------------------#
#   Backup and reset BITS

Ren %Systemroot%\SoftwareDistribution\DataStore DataStore.bak
Ren %Systemroot%\SoftwareDistribution\Download Download.bak
Ren %Systemroot%\System32\catroot2 catroot2.bak

sc.exe sdset bits D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)
sc.exe sdset wuauserv D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)

#----------------------------------------------------------------------------------------#
#   Reregister BITS .dlls

cd /d %windir%\system32

regsvr32.exe atl.dll
regsvr32.exe urlmon.dll
regsvr32.exe mshtml.dll
regsvr32.exe shdocvw.dll
regsvr32.exe browseui.dll
regsvr32.exe jscript.dll
regsvr32.exe vbscript.dll
regsvr32.exe scrrun.dll
regsvr32.exe msxml.dll
regsvr32.exe msxml3.dll
regsvr32.exe msxml6.dll
regsvr32.exe actxprxy.dll
regsvr32.exe softpub.dll
regsvr32.exe wintrust.dll
regsvr32.exe dssenh.dll
regsvr32.exe rsaenh.dll
regsvr32.exe gpkcsp.dll
regsvr32.exe sccbase.dll
regsvr32.exe slbcsp.dll
regsvr32.exe cryptdlg.dll
regsvr32.exe oleaut32.dll
regsvr32.exe ole32.dll
regsvr32.exe shell32.dll
regsvr32.exe initpki.dll
regsvr32.exe wuapi.dll
regsvr32.exe wuaueng.dll
regsvr32.exe wuaueng1.dll
regsvr32.exe wucltui.dll
regsvr32.exe wups.dll
regsvr32.exe wups2.dll
regsvr32.exe wuweb.dll
regsvr32.exe qmgr.dll
regsvr32.exe qmgrprxy.dll
regsvr32.exe wucltux.dll
regsvr32.exe muweb.dll
regsvr32.exe wuwebv.dll

#----------------------------------------------------------------------------------------#
#   Winsock reset 

netsh winsock reset


#----------------------------------------------------------------------------------------#
#   BITS queue clear

bitsadmin.exe /reset /allusers

#----------------------------------------------------------------------------------------#
#   Updater

$updateSession = New-Object -ComObject 'Microsoft.Update.Session'
$updateSearcher = $updateSession.CreateupdateSearcher()
$searchResult = $updateSearcher.Search("IsInstalled=0 and IsHidden=0")
$updatesToDownload = New-Object -ComObject "Microsoft.Update.UpdateColl"
ForEach($update in $searchResult.Updates){
    if($update.IsDownloaded -eq $false){
        $updatesToDownload.Add($update) | Out-Null
    }
}
if($updatesToDownload.Count -gt 0){
    $downloader = $updateSession.CreateUpdateDownloader()
    $downloader.Updates = $updatesToDownload
    $downloadResult = $downloader.Download()

    $numDownloaded = 0
    0..($updatesToDownload.Count - 1) | % {
        $result = $downloadResult.GetUpdateResult($_).ResultCode
        if($result -eq 2 -or $result -eq 3){$numDownloaded++}
    }
    return $numDownloaded
}
else{return 0}


#----------------------------------------------------------------------------------------#
#   Reg WUS

Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate]
"DisableDualScan"=hex(b):01,00,00,00,00,00,00,00
"DisableWindowsUpdateAccess"=hex(b):01,00,00,00,00,00,00,00
"ElevateNonAdmins"=dword:00000001
"WUServer"="http://uk-hub3-m1002.group.wan:8530"
"WUStatusServer"="http://uk-hub3-m1002.group.wan:8530"
"UpdateServiceUrlAlternate"=""
"TargetGroupEnabled"=dword:00000001
"TargetGroup"="Production"

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU]
"AutoInstallMinorUpdates"=dword:00000001
"NoAUShutdownOption"=dword:00000001
"NoAUAsDefaultShutdownOption"=dword:00000001
"RescheduleWaitTimeEnabled"=dword:00000000
"DetectionFrequencyEnabled"=dword:00000000
"RebootWarningTimeoutEnabled"=dword:00000000
"RebootRelaunchTimeoutEnabled"=dword:00000001
"RebootRelaunchTimeout"=dword:0000003c
"UseWUServer"=dword:00000001
"NoAutoRebootWithLoggedOnUsers"=dword:00000001
"NoAutoUpdate"=dword:00000000
"AUOptions"=dword:00000004
"ScheduledInstallDay"=dword:00000000
"ScheduledInstallTime"=dword:0000000a
"ScheduledInstallEveryWeek"=dword:00000001


#########################

@ECHO OFF
 echo Simple Script to Reset / Clear Windows Update
 echo.

 echo.
 attrib -h -r -s %windir%\system32\catroot2
 attrib -h -r -s %windir%\system32\catroot2\*.*
 net stop wuauserv
 net stop CryptSvc
 net stop BITS
 ren %windir%\system32\catroot2 catroot2.old
 ren %windir%\SoftwareDistribution sold.old
 ren "%ALLUSERSPROFILE%\application data\Microsoft\Network\downloader" downloader.old
 net Start BITS
 net start CryptSvc
 net start wuauserv
 echo.
 echo Task completed successfully...
 echo.
