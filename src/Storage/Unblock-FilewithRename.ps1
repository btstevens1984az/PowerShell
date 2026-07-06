# Purpose: Unblock-FilewithRename — Storage management and disk operations.

$path = 'C:\Downloads\DirWithFilesToCheck'

$files = Get-ChildItem -Path $path -File
# replace the first arg with the second...  replace a - with a blank
foreach ($file in $files) { 
 Unblock-File -Path $file.FullName
 $newname = $file.FullName -replace '\-', ' '
 Rename-Item -Path $file.FullName -NewName $newname
 }

Get-ChildItem -Path $path