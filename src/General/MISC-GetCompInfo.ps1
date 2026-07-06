# Purpose: MISC-GetCompInfo — General-purpose PowerShell utilities.
#   James Wylde

#----------------------------------------------------------------------------------------#
#   Modules

Invoke-Command -ComputerName '19.131.54.185' -ScriptBlock { Get-ComputerInfo -Property *BIOS* }

##cmd

systeminfo.exe | find.exe /i "OS Version:"