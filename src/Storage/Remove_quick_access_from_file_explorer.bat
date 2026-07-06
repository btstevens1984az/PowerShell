@echo off

net file 1>nul 2>nul && goto :run || powershell -ex unrestricted -Command "Start-Process -Verb RunAs -FilePath '%comspec%' -ArgumentList '/c %~fnx0 %*'"
goto :eof
:run

echo "This removes quick access from file explorer"
REG ADD HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer /v HubMode /t REG_DWORD /d 1 /f
taskkill /F /IM explorer.exe & start explorer
cls
echo "Restarted explorer.exe, please check if Quick access menu is gone."
pause