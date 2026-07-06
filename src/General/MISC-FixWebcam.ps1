# Purpose: MISC-FixWebcam — General-purpose PowerShell utilities.
# Windows Intergrated Camera relies on frameserver service
    net start frameserver


# If fails to start

reg.exe Add "HKLM\SOFTWARE\Microsoft\Windows Media Foundation\Platform" /v EnableFrameServerMode /t REG_DWORD /d 0 /f && reg.exe Add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows Media Foundation\Platform" /v EnableFrameServerMode /t REG_DWORD /d 0 /f