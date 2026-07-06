# Purpose: Search-Files — Storage management and disk operations.
# change to dir to search
# set pattern enclose in quotes if spaces or special characters are being searched for

# $SearchPattern = 'whatsup'


Get-ChildItem -recurse | Select-String -pattern "StartType" | format-list


# Get-ChildItem -Recurse filespec | Select-String -pattern "StartType" | Select-Object -Unique Path |fl *


#this works well to list the files with the pattern found - just names no other info
foreach ($file in Get-ChildItem | Select-String -pattern "StartType" | Select-Object -Unique path) {$file.path}




# this returns name of file, the line number and the syntax of the line

Get-ChildItem -recurse | Select-String -pattern "StartType" | select-object FileName, LineNumber, Line | format-list
