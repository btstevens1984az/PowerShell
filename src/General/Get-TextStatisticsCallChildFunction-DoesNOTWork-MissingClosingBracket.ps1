# Purpose: Get-TextStatisticsCallChildFunction DoesNOTWork MissingClosingBracket — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE: 1/28/2009
#
# KEYWORDS: Function, Get-Content, Measure-Object
#
# COMMENTS: This script provides statistical information
# about a text file. It then calls a child function to illustrate that
# variables created within the scope of a function are available
# to child functions.
# *** DOES NOT WORK *** Missing closing bracket ***
#
# PowerShell Best Practices
# ------------------------------------------------------------------------
Function Get-TextStatistics($path)
{
 Get-Content -path $path |
 Measure-Object -line -character -word
 Write-Path
# Here is where the missing bracket goes

Function Write-Path()
{
 "Inside Write-Path the `$path variable is equal to $path"
}

Get-TextStatistics("C:\fso\test.txt")
"Outside the Get-TextStatistics function `$path is equal to $path"
