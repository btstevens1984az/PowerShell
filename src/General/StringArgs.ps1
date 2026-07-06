# Purpose: StringArgs — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE: 5/10/2009
#
# KEYWORDS: $args automatic variable, arguments,
# array
# COMMENTS: This illustrates the way the $args
# handles an array from the command line
#
# ex: StringArgs.ps1 "string1","String2"
#
# ------------------------------------------------------------------------

'The value of arg0 ' + $args[0] + ' the value of arg1 ' + $args[1] 