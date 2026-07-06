# Purpose: Patching.UpdateRepair — Windows Update and patch management.
Write-Output "===Windows Update Repair==="
##Stop update services
$bits = Get-Service bits
IF ($bits.Status -eq 'Running') {
    Stop-Service bits -Force
}
$cryptSvc = Get-Service cryptsvc
IF ($cryptSvc.Status -eq 'Running') {
    Stop-Service cryptsvc -Force
}
$wuauServ = Get-Service wuauserv
IF ($wuauServ.Status -eq 'Running') {
    Stop-Service wuauserv -Force
}

##Delete Windows Updates downloads & cache
Get-ChildItem "C:\Windows\system32\catroot2\*" -Recurse | Remove-Item -Force -EA 0 -Confirm:$False -Recurse
Get-ChildItem "C:\Windows\SoftwareDistribution\*" -Recurse | Remove-Item -Force -EA 0 -Confirm:$False -Recurse

##Reset proxy
netsh winhttp reset proxy

##Reset BITS
sc.exe sdset bits "D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)"
sc.exe sdset wuauserv "D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)"

##Re-register DLLs
regsvr32.exe atl.dll /s
regsvr32.exe urlmon.dll /s
regsvr32.exe mshtml.dll /s
regsvr32.exe shdocvw.dll /s
regsvr32.exe browseui.dll /s
regsvr32.exe jscript.dll /s
regsvr32.exe vbscript.dll /s
regsvr32.exe scrrun.dll /s
regsvr32.exe msxml.dll /s
regsvr32.exe msxml3.dll /s
regsvr32.exe msxml6.dll /s
regsvr32.exe actxprxy.dll /s
regsvr32.exe softpub.dll /s
regsvr32.exe wintrust.dll /s
regsvr32.exe dssenh.dll /s
regsvr32.exe rsaenh.dll /s
regsvr32.exe gpkcsp.dll /s
regsvr32.exe sccbase.dll /s
regsvr32.exe slbcsp.dll /s
regsvr32.exe cryptdlg.dll /s
regsvr32.exe oleaut32.dll /s
regsvr32.exe ole32.dll /s
regsvr32.exe shell32.dll /s
regsvr32.exe initpki.dll /s
regsvr32.exe wuapi.dll /s
regsvr32.exe wuaueng.dll /s
regsvr32.exe wuaueng1.dll /s
regsvr32.exe wucltui.dll /s
regsvr32.exe wups.dll /s
regsvr32.exe wups2.dll /s
regsvr32.exe wuweb.dll /s
regsvr32.exe qmgr.dll /s
regsvr32.exe qmgrprxy.dll /s
regsvr32.exe wucltux.dll /s
regsvr32.exe muweb.dll /s
regsvr32.exe wuwebv.dll /s

##Reset winsock
netsh winsock reset

##Start update services
Start-Service bits
Start-Service cryptsvc
Start-Service wuauserv