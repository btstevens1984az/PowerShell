# Purpose: ConvertToFahrenheit include2 — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE: 9/24/2008
#
# KEYWORDS: Converts Celsius to Fahrenheit
#
# COMMENTS: This script converts Celsius to Fahrenheit
# It uses command line parameters and an include file
#
#
#
# ------------------------------------------------------------------------
Param($Celsius)

$includeFile = "c:\data\scriptingGuys\ConversionFunctions.ps1"
if(!(test-path -path $includeFile))
  {
   "Unable to find $includeFile"
   Exit
  }
. $includeFile
ConvertToFahrenheit($Celsius)