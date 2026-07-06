# Purpose: MISC-Lockouts — Security auditing and compliance checks.
#   James Wylde
Clear-Host

$computerName = Read-Host "Machine"
$userName = Read-Host "Username"



Invoke-Command -ComputerName $computerName -Scriptblock {

$nL =  "`r`n"

###### Winrm start
Write-Host "Starting Winrm...." -ForegroundColor Green 


#psservice.exe \\$using:computerName -accepteula start winrm



Start-Sleep -S 5

###### End processes

Write-Host "Stopping programs...." -ForegroundColor Green 

Stop-Process -Name Teams -Force -EA SilentlyContinue

Get-Process Lync* | Stop-Process -f
Stop-Process -Name Outlook -Force
taskkill /f /im ucmapi.exe

#Stop-Process -Name Notepad -Force -EA SilentlyContinue



###### Clear credmanager

Write-Host "Clearing credman...." -ForegroundColor Green 


cmdkey.exe /list | ForEach-Object{if($_ -like "*Target:*"){cmdkey /del:($_ -replace " ","" -replace "Target:","")}} -Verbose
#cmdkey /list:$using:userName | ForEach-Object{if($_ -like "*Target:*"){cmdkey /del:($_ -replace " ","" -replace "Target:","")}} -Verbose
# for /F "tokens=1,* delims= " %G in ('cmdkey /list ^| findstr Adobe') do cmdkey /delete %H
#paexec.exe \\$computerName cmd /C "for /F "tokens=1,2 delims= " %G in ('cmdkey /list ^| findstr Target') do cmdkey /delete %H"




###### Chrome

Write-Host "Clearing Chrome...." -ForegroundColor Green 

Remove-Item -path "C:\Users\$using:userName\AppData\Local\Google\Chrome\User Data\Default\Cache\*" -Recurse -Force -EA SilentlyContinue -Verbose
Remove-Item -path "C:\Users\$using:userName\AppData\Local\Google\Chrome\User Data\Default\Cache2\entries\*" -Recurse -Force -EA SilentlyContinue -Verbose
Remove-Item -path "C:\Users\$using:userName\AppData\Local\Google\Chrome\User Data\Default\Cookies" -Force -EA SilentlyContinue -Verbose
Remove-Item -path "C:\Users\$using:userName\AppData\Local\Google\Chrome\User Data\Default\Media Cache" -Force -EA SilentlyContinue -Verbose
Remove-Item -path "C:\Users\$using:userName\AppData\Local\Google\Chrome\User Data\Default\Cookies-Journal" -Force -EA SilentlyContinue -Verbose



###### IE

Write-Host "Clearing IE...." -ForegroundColor Green 

Remove-Item -path "C:\Users\$using:userName\AppData\Local\Microsoft\Windows\Temporary Internet Files\*" -Recurse -Force -EA SilentlyContinue -Verbose
Remove-Item -path "C:\Users\$using:userName\AppData\Local\Microsoft\Windows\WER\*" -Recurse -Force -EA SilentlyContinue -Verbose



###### Regkeys

Write-Host "Clearing Regkeys...." -ForegroundColor Green 

Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Internet Explorer" -Name "IntelliForms" -EA SilentlyContinue -Verbose



###### Windows Temp

Write-Host "Clearing Temp...." -ForegroundColor Green 

Remove-Item -path "C:\Windows\Temp\*" -Recurse -Force -EA SilentlyContinue -Verbose


###### Teams

Write-Host "Clearing Teams...." -ForegroundColor Green 

Remove-Item -Path "%AppData%\Microsoft\teams\cache\*" -Recurse -Force -EA SilentlyContinue -Verbose
Remove-Item -Path "%AppData%\Microsoft\teams\gpucache\*" -Recurse -Force -EA SilentlyContinue -Verbose



###### Skype

Write-Host "Clearing Skype...." -ForegroundColor Green 

Remove-Item -Path "%LOCALAPPDATA%\Microsoft\Office\16.0\Lync\*" -Recurse -Force -EA SilentlyContinue -Verbose

}


# rundll32.exe keymgr.dll,KRShowKeyMgr
# Control userpasswords2
# net user Administrator Kappa21

