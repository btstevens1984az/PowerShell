# Purpose: WindowsUpdateRefresh — Windows Update and patch management.
Write-Host "^=^> Stopping services..." -back Black -fore Green

$services = @("bits", "wuauserv", "appidsvc", "cryptsvc")
foreach ($service in $services){
    Stop-Service $service
}

cls
Write-Host "^=^> Deleting qmgr*.dat files..." -back Black -fore Green
Remove-Item "$env:ALLUSERSPROFILE\Application Data\Microsoft\Network\Downloader\qmgr*.dat"

cls
Write-Host "^=^> Deleting SoftwareDistribution folders..." -back Black -fore Green
$deleteBaks = @("$Env:SystemRoot\winsxs\pending.xml.bak", "$Env:SystemRoot\SoftwareDistribution.bak", "$Env:SystemRoot\system32\Catroot2.bak", "$Env:SystemRoot\WindowsUpdate.log.bak")

foreach ($deleteBak in $deleteBaks){
    if(Test-Path $deleteBak){
        Write-Host "Found $deleteBak, deleting..." -back Black -fore Green
        Remove-Item $deleteBak -Force
    }
}

$backups = @("$Env:SystemRoot\winsxs\pending.xml", "$Env:SystemRoot\SoftwareDistribution", "$Env:SystemRoot\system32\Catroot2", "$Env:SystemRoot\WindowsUpdate.log")

foreach ($backup in $backups){
    if(Test-Path $backup){
        Write-Host "Found $backup, backing up..." -back Black -fore Green
        takeown /f $backup
        attrib -r -s -h /s /d $backup
        Rename-Item $backup -NewName "$backup.bak"
    }
}

Write-Host "^=^> Resetting BITS and WUAUSERV to default security descriptors..." -back Black -fore Green
Start-Process sc.exe -ArgumentList 'sdset bits D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)'
Start-Process sc.exe -ArgumentList 'sdset wuauserv D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)'

Write-Host "^=^> Reregistering BITS and Windows Update files..." -back Black -fore Green
$dlls = @("atl.dll","urlmon.dll","mshtml.dll","shdocvw.dll","browseui.dll","jscript.dll","vbscript.dll","scrrun.dll","msxml.dll","msxml3.dll","msxml6.dll","actxprxy.dll","softpub.dll","wintrust.dll","dssenh.dll","rsaenh.dll","gpkcsp.dll","sccbase.dll","slbcsp.dll","cryptdlg.dll","oleaut32.dll","ole32.dll","shell32.dll","initpki.dll","wuapi.dll","wuaueng.dll","wuaueng1.dll","wucltui.dll","wups.dll","wups2.dll","wuweb.dll","qmgr.dll","qmgrprxy.dll","wucltux.dll","muweb.dll","wuwebv.dll")
foreach ($dll in $dlls){
    regsvr32.exe /s $dll
    Write-Host "Reregistered $dll" -back Black -fore Yellow
}

Write-Host "^=^> Resetting Winsock..." -back Black -fore Green
netsh winsock reset

Write-Host "^=^> Resetting WinHTTP proxy..." -back Black -fore Green
netsh winhttp reset proxy


Write-Host "^=^> Configuring service startup types..." -back Black -fore Green
foreach ($Service in $Services){
    Set-Service -Name $Service -StartupType Automatic
    Write-Host "$Service set to Automatic Startup" -back Black -fore Yellow
}

Write-Host "^=^> Restarting services..." -back Black -fore Green
foreach ($Service in $Services){
    Start-Service -Name $Service
    Write-Host "$Service has been started." -back Black -fore Yellow
}