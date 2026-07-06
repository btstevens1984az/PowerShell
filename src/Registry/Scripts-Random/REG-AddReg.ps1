# Purpose: REG-AddReg — Windows registry read and write operations.
#   James Wylde

#----------------------------------------------------------------------------------------#
#   Modules


  Invoke-Command -Computername 69.171.70.42 -ArgumentList $arguments -Scriptblock {

    Stop-Process -Name Teams -Force

    reg.exe Add "HKLM\Software\Microsoft\Windows NT\Current Version\AppCompatFlags\Layers" /v "C:\Users\USER\AppData\Local\Microsoft\Teams\current\teams.exe" /T REG_SZ /d "WIN7RTM" /F
    
    }


Invoke-Command -Computername 69.171.70.42  -Scriptblock {

Stop-Process -Name Teams -Force
  
reg.exe Add "HKLM\Software\Microsoft\Windows NT\Current Version\AppCompatFlags\Layers" /v "C:\ProgramData\TayloCl\Microsoft\Teams\Update.exe" /T REG_SZ /d "WIN7RTM" /F
      
}


reg delete "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Terminal Server Client\Servers\dinner"

reg.exe Add "HKLM\System\CurrentControlSet\Services\Current Version\AppCompatFlags\Layers" /v "C:\ProgramData\TayloCl\Microsoft\Teams\Update.exe" /T REG_SZ /d "WIN7RTM" /F

reg.exe Add "HKLM\SYSTEM\CurrentControlSet\Services\ncasvc" /v Start /t REG_DWORD /d 2 /f

#cscript.exe launching on startup
reg.exe Add "HKLM\SOFTWARE\Microsoft\Windows Script Host\Settings" /v Enabled /t REG_DWORD /d 1 /f
