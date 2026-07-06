# Purpose: MeasureAddOneR2Function — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE: 2/17/2009
#
# KEYWORDS: function, demo, Process block,
# Measure-Object
# COMMENTS: This script displays the entry into a function
#
# Best Practices
# ------------------------------------------------------------------------
Function AddOneR2
{ 
   Process { 
   "add one function r2"
   $_ + 1
  }
} #end AddOneR2

Measure-Command {1..50000 | addOneR2 }