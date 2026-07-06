# Purpose: GetExplorer — General-purpose PowerShell utilities.
# GetExplorer.ps1
# ed wilson, msft, 11/8/2008

Get-WmiObject -Class win32_process -Filter "name = 'explorer.exe'" | 
Format-List -Property name, ProcessID, page*, peak*, w*
