# Purpose: ConvertToFahrenheit — General-purpose PowerShell utilities.
Param($Celsius)
Function ConvertToFahrenheit($Celsius)
{
 "$Celsius Celsius equals $((1.8 * $Celsius) + 32) Fahrenheit"
} #end ConvertToFahrenheit
ConvertToFahrenheit($Celsius)
