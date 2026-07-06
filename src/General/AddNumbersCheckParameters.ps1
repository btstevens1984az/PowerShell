# Purpose: AddNumbersCheckParameters — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE: 5/16/2009
#
# KEYWORDS: Uses parameter arguments, and 
# parameter validation attributes to check the input
# supplied to the script.
# COMMENTS: This script accepts two mandatory parameters
# the first parameter must be a number between 1 and 10 and
# the second must not be null. 
#
#
# ------------------------------------------------------------------------
#requires -version 2.0
Param(
             [Parameter(mandatory=$true,
                                 Position=0,
                                 HelpMessage="A number between 1 and 10")]
             [alias("fn")]
             [ValidateRange(1,10)]
             $FirstNumber,
             [Parameter(mandatory=$true,
                                 Position=1,
                                 HelpMessage="Not null or empty")]
             [alias("ln")]
             [int16]
             [ValidateNotNullOrEmpty()]
             $lastnumber
)

$firstnumber*$lastnumber