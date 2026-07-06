# Purpose: ConvertToFahrenheit include — General-purpose PowerShell utilities.
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

. C:\data\scriptingGuys\ConversionFunctions.ps1
ConvertToFahrenheit($Celsius)