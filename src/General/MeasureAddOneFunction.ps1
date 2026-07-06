# Purpose: MeasureAddOneFunction — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE: 2/17/2009
#
# KEYWORDS: Function, Measure-Command
#
# COMMENTS: This script measures the time to add one
# to a large number of numbers using a function
#
# Best Practices
# ------------------------------------------------------------------------
Function AddOne
{  
  "Add One Function"
  While ($input.moveNext())
   {
     $input.current + 1
   }
}

Measure-Command { 1..50000 | addOne }