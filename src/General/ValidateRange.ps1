# Purpose: ValidateRange — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE: 5/16/2009
#
# KEYWORDS: ValidateRange parameter attribute,
# command line parameter
# COMMENTS: This script uses the validaterange parameter
# attribute to ensure the number supplied is between 1 and 5.
#
#
# ------------------------------------------------------------------------
#Requires -version 2.0
Param( 
             [validateRange(1,5)]
             $number
            )

Function Set-Number($number)
{
 $number * 2
} #end Set-Number

# *** Entry point to script ***
Set-Number($number)