# Purpose: MISC-PaExecMSI — PowerShell automation.
#   James Wylde


paexec.exe @computers.txt -s msiexec.exe /i \\167.49.161.230\8x8\work-64-msi-v7.5.1-2.msi /quiet


msiexec.exe /i c:\temp\work-64-msi-v7.5.1-2.msi /quiet