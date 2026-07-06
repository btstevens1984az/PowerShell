# Purpose: GetProcessesDisplayTempFile — Storage management and disk operations.
# ------------------------------------------------------------------------
# DATE: 4/4/2009
# VERSION 1.0
#
# KEYWORDS: [io.path], GetTempFileName, out-null
#
# COMMENTS: This script creates a temporary file, 
# obtains a collection of process information and writes 
# that to the temporary file. It then displays that file via
# Notepad and then removes the temporary file when 
# done. 
#
# ------------------------------------------------------------------------
#This both creates the file name as well as the file itself
$tempFile = [io.path]::GetTempFileName()
Get-Process >> $tempFile
#Piping the Notepad filename to the Out-Null cmdlet halts
#the script execution
Notepad $tempFile | Out-Null
#Once the file is closed the temporary file is closed and it is
#removed
Remove-Item $tempFile