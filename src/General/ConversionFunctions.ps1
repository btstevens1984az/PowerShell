# Purpose: ConversionFunctions — General-purpose PowerShell utilities.
# ---------------------------------------------------------------------------------------
# ConversionFunctions.ps1
# ed wilson, 9/24/2008
# Six functions to convert meters/feet and fahrenheit/celsius
# These allow for metric conversions
# 
# --------------------------------------------------------------------------------------
Function Script:ConvertToMeters($feet)
{
  "$feet feet equals $($feet*.31) meters"
} #end ConvertToMeters

Function Script:ConvertToFeet($meters)
{
 "$meters meters equals $($meters * 3.28) feet"
} #end ConvertToFeet

Function Script:ConvertToFahrenheit($celsius)
{
 "$celsius celsius equals $((1.8 * $celsius) + 32 ) fahrenheit"
} #end ConvertToFahrenheit

Function Script:ConvertTocelsius($fahrenheit)
{
 "$fahrenheit fahrenheit equals $( (($fahrenheit - 32)/9)*5 ) celsius"
} #end ConvertTocelsius

Function Script:ConvertToMiles($kilometer)
{
  "$kilometer kilometers equals $( ($kilometer *.6211) ) miles"
} #end convertToMiles

Function Script:ConvertToKilometers($miles)
{
  "$miles miles equals $( ($miles * 1.61) ) kilometers"
} #end convertToKilometers

