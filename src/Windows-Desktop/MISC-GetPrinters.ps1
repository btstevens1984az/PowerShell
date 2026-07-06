# Purpose: MISC-GetPrinters — Windows desktop configuration and management.
#   James Wylde

Get-WmiObject Win32_Printer -Computername 27.160.97.64


wmic printer get name,default