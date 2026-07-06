# Purpose: MISC-ReregisterDLLs — General-purpose PowerShell utilities.
for %i in (%windir%\system32\*.dll) do regsvr32.exe /s %i