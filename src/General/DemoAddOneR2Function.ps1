# Purpose: DemoAddOneR2Function — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE: 2/17/2009
#
# KEYWORDS: function, demo, Process block
#
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

1..5 | addOneR2 