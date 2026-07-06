# Purpose: DemoAddOneFilter — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE: 2/17/2009
#
# KEYWORDS: filter, demo
#
# COMMENTS: This script displays the entry into a filter 
#
# Best Practices
# ------------------------------------------------------------------------
Filter AddOne
{ 
 "add one filter"
  $_ + 1
}

1..5 | addOne 