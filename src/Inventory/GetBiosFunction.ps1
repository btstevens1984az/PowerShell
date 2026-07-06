# Purpose: GetBiosFunction — Hardware and software inventory collection.
# ------------------------------------------------------------------------
# DATE: 2/15/2009
#
# KEYWORDS: param, begin, process, end, function
# environmental drive, function
# COMMENTS: This script creates a function that uses
# the begin, process, and the end keywords. It also uses
# the param keyword to define the input parameters to the
# function. 
#
# PowerShell Best Practices
# ------------------------------------------------------------------------
Function Get-Bios
{
 Param ( $computer = $env:ComputerName)
 Begin {"Getting Bios information from $computer"}
 Process { Gwmi win32_bios -computer $computer }
 End {"Bios information obtained from $computer" }
}

Get-Bios