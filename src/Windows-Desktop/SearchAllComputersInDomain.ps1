# Purpose: SearchAllComputersInDomain — Windows desktop configuration and management.
# ------------------------------------------------------------------------
# DATE: 3/5/2009
#
# KEYWORDS: DirectoryServices.DirectorySearcher,
# DirectorySearcher, System.DIrectoryServices.DirectorySearcher,
# Foreach-Object, begin, process, end, findall method, hsg
# COMMENTS: This script uses the DirectoryServices.DirectorySearcher
# .NET Framework class to search active directory. It then returns
# all the properties for each computer that is found.
#
# HSG 3/16/2009
# ------------------------------------------------------------------------

$Filter = "ObjectCategory=computer"
$Searcher = New-Object System.DirectoryServices.DirectorySearcher($Filter)
$Searcher.Findall() | 
Foreach-Object `
  -Begin { "Results of $Filter query: " } `
  -Process { $_.properties ; "`r"} `
  -End { [string]$Searcher.FindAll().Count + " $Filter results were found" }