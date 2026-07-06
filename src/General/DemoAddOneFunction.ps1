# Purpose: DemoAddOneFunction — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# NAME:DemoAddOneFunction.ps1
# DATE: 2/17/2009
#
# KEYWORDS: Function
#
# COMMENTS: This script demonstrates calling a function in a pipeline
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

1..5 | addOne 