# Purpose: Get-TextStatistics — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE: 1/28/2009
#
# KEYWORDS: Function, Get-Content, Measure-Object
#
# COMMENTS: This script provides statistical information
# about a text file. 
#
# PowerShell Best Practices
# ------------------------------------------------------------------------
Function Get-TextStatistics($path)
{
 Get-Content -path $path |
 Measure-Object -line -character -word
}

Get-TextStatistics("C:\fso\test.txt")