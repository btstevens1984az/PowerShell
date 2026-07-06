# Purpose: REG-Misc — Windows registry read and write operations.
#   James Wylde

#----------------------------------------------------------------------------------------#
#   Modules

#NLA Delayed Start
reg.exe Add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc" /v Start /T REG_SZ /d 2 /F

#AutoHide TaskBar
reg.exe add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3" /v Settings /T REG_BINARY /d "30000000FEFFFFFF03020000030000003E00000028000000000000001004000080070000380400006000000001000000" /f

#Bypass SCCM remote approval
reg.exe Add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\SMS\Client\Client Components\Remote Control" /v "Permission Required" /t REG_DWORD /d 0 /f

#Bypass USB Bitlocked Required GPO
reg.exe Add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Policies\Microsoft\FVE" /v "RDVDenyWriteAccess" /t REG_DWORD /d 0 /f
