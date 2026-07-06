# Purpose: DemoFunctionParameters — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE: 2/16/2009
#
# KEYWORDS: function, begin, process, end, parameters,
# array
# COMMENTS: This script uses the three parameters: 
# begin, process, and end to add numbers
# uses the 1..4 to create an array of numbers
#
#
# ------------------------------------------------------------------------

Function test
{
 Begin {"Beginning test" }
 Process {$_ + 1 }
 End { "Completed test" }
} #end test

1..4 | test