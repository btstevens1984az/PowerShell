# Purpose: SFB-Fix — General-purpose PowerShell utilities.
Get-Process Lync* | Stop-Process -f
Stop-Process -Name Outlook -Force
taskkill /f /im ucmapi.exe
Remove-Item -Path "C:\Users\haggast\AppData\Local\Microsoft\Office\16.0\Lync*" -Force -Confirm:$false
Start-Process "C:\Program Files (x86)\Microsoft Office\Office16\ucmapi.exe"