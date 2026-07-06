# Purpose: FindLargeDocs — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE: 2/15/2009
#
# KEYWORDS: Business logic, where-object, function,
# filter
# COMMENTS: This script uses a function to find doc files
# and then passes results to a filter to find large files
#
# PowerShell Best Practices
# ------------------------------------------------------------------------

Function Get-Doc($path)
{
 Get-ChildItem -Path $path -include *.doc,*.docx,*.dot -recurse
} #end Get-Doc

Filter LargeFiles($size)
{
  $_ |
  Where-Object { $_.length -ge $size }
} #end LargeFiles

Get-Doc("C:\FSO") |  LargeFiles 1000