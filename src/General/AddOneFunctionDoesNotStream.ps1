# Purpose: AddOneFunctionDoesNotStream — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE: 2/17/2009
#
# KEYWORDS: demo function
#
# COMMENTS: This function tries to use $_ automatic
# variable, but since a function does not stream, it only
# does the first number ... To access all the data from the 
# pipeline .. you need to use the $input automatic variable
#
# Best Practices
# ------------------------------------------------------------------------
Function AddOne
{  
  "Add One Function"
  
   $_ + 1
}

1..5 | addOne 