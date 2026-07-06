# Purpose: CreateFileNameFromDate — Storage management and disk operations.
# ------------------------------------------------------------------------
# DATE:12/15/2008
#
# KEYWORDS: .NET framework, io.path, get-date
# file, new-item, Standard Date and Time Format Strings
# regular expression, fef, pass by reference
#
# COMMENTS: This script creates an empty text file
# based upon the date-time stamp. uses format string
# to specify a sortable date. uses getInvalidFileNameChars
# method to get all the invalid characters that are not allowed
# in a file name. It assumes there is a folder named fso off the
# c:\ drive. If the folder does not exist, the script will fail. 
#
# ------------------------------------------------------------------------
Function GetFileName([ref]$fileName)
{
 $invalidChars = [io.path]::GetInvalidFileNamechars() 
 $date = Get-Date -format s
 $fileName.value = ($date.ToString() -replace "[$invalidChars]","-") + ".txt"
}

$fileName = $null
GetFileName([ref]$fileName)
new-item -path c:\fso -name $filename -itemtype file