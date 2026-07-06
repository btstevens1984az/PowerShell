# Purpose: StringArgsArray1 — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE: 5/10/2009
#
# KEYWORDS: $args automatic variable, arguments,
# array
# COMMENTS: This illustrates the way the $args
# handles an array from the command line
#
# ex: StringArgs.ps1 "string1","String2"
# Does not produce expected results.
#
# ------------------------------------------------------------------------
$args | Foreach-Object {
'The value of arg0 ' + $_ + ' the value of arg1 ' + $_ 
}