# Purpose: ConvertToMeters — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE: 2/20/2009
#
# KEYWORDS: Function
#
# COMMENTS: This script converts meters to feet
#
# PowerShell Best Practices
# ------------------------------------------------------------------------
Function Script:ConvertToMeters($feet)
{
  "$feet feet equals $($feet*.31) meters"
} #end ConvertToMeters
$feet = 5
ConvertToMeters -Feet $feet