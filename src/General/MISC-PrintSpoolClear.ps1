# Purpose: MISC-PrintSpoolClear — General-purpose PowerShell utilities.
#   James Wylde

#----------------------------------------------------------------------------------------#
#   Modules

Invoke-Command -ComputerName 168.23.139.1 -Scriptblock {

Stop-Service -Name Spooler -Force

Move-Item -Path "$env:SystemRoot\System32\spool\PRINTERS\*.*" -Destination 'C:\temp\' -Force

Remove-Item -Path "$env:SystemRoot\System32\spool\PRINTERS\*.*"

Start-Service -Name Spooler

}
