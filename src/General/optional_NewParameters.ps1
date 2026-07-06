# Purpose: optional NewParameters — General-purpose PowerShell utilities.
#New Parameters
###############################################################################
# Recurse Depth

New-Item -ItemType File -Path 'C:\Temp\Folder1\Folder2\Folder3\Folder4\File.txt' -Force -Value 'Hello, world.'

cls; Get-ChildItem 'C:\Temp'
cls; Get-ChildItem 'C:\Temp' -Recurse
cls; Get-ChildItem 'C:\Temp' -Recurse -Depth 2

cls; Get-ChildItem 'C:\Program Files' -Directory -Recurse
cls; Get-ChildItem 'C:\Program Files' -Directory -Recurse -Depth 1

###############################################################################
# FileVersionInfo

$pid
Get-Process -Id $pid
Get-Process -Id $pid -FileVersionInfo | Format-List *version*
Get-Process -FileVersionInfo -ErrorAction SilentlyContinue| Select-Object *version*,FileName,FileDescription,ProductName | Out-GridView