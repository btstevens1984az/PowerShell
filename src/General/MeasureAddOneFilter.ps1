# Purpose: MeasureAddOneFilter — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE: 2/17/2009
#
# KEYWORDS: filter, demo, measure-command
#
# COMMENTS: This script measures the time it 
# takes to add the number one to a large array. 
#
# Best Practices
# ------------------------------------------------------------------------
Filter AddOne
{ 
 "add one filter"
  $_ + 1
}

Measure-Command { 1..50000 | addOne }