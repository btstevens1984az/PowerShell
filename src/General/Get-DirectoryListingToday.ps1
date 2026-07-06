# Purpose: Get-DirectoryListingToday — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE: 2/20/2009
#
# KEYWORDS: Function, Param, Get-Date, Get-Childitem
#
# COMMENTS: This script illustrates the use of the param 
# work in a function. It will get a directory listing of a specific
# file type, and optionally list only files written to in the current
# date.
#
# PowerShell Best Practices
# ------------------------------------------------------------------------
Function Get-DirectoryListing
{
 Param(
             [String]$Path,
             [String]$Extension = "txt",
             [Switch]$Today
            )
  If($Today)
    {
     Get-ChildItem -Path $path\* -include *.$Extension |
     Where-Object { $_.LastWriteTime -ge (Get-Date).Date }
    }
  ELSE 
   {
    Get-ChildItem -Path $path\* -include *.$Extension
   }
} #end Get-DirectoryListing

# *** Entry to script ***
Get-DirectoryListing -p c:\fso  -t