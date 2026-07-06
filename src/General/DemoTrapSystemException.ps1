# Purpose: DemoTrapSystemException — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE: 2/7/2009
#
# KEYWORDS: Demo, Error Trap, Trap Error
#
# COMMENTS: This illustrates trapping an error.
# $ErrorActionPreference will control NON-Terminating errors.
# Trap will control Terminiating errors. 
# Try the different error action preferences: stop, continue, silentlycontinue, inquire
# [SystemException] is the grand dady of all exceptions.
# ------------------------------------------------------------------------
Function My-Test( [int]$myinput)
{
 
 "It worked"
} #End my-test function
# *** Entry Point to Script ***

Trap [SystemException] { "error trapped" ; continue }
My-Test -myinput "string"
"After the error"
