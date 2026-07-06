# Purpose: ConvertUseFunctions — General-purpose PowerShell utilities.
# --------------------------------------------------------------------------------------------------------------------
# ConvertUseFunctions.ps1
# ed wilson, 9/26/2008
#
# HSG article
# uses an include file with the conversion functions.
# Due to having the include fine inside a function, then all the functions from the include
# file end up in the function scope, and are not available outside. To combat this, have to
# add the script level scope tag to the function. Key Point: Script:functionName is the 
# modifier for a function. For a variable is $script:variablename. 
#
# ------------------------------------------------------------------------------------------------------------------
Param($action,$value,[switch]$help)

Function GetHelp()
{
  if($help)
  {
   "choose conversion: M(eters), F(eet) C(elsius),Fa(renheit),Mi(les),K(ilometers) and value"
   " Convert -a M -v 10 converts 10 meters to feet."
  } #end if help
} #end getHelp

Function GetInclude()
{
 $includeFile = "c:\data\scriptingGuys\ConversionFunctions.ps1"
 if(!(test-path -path $includeFile))
   {
    "Unable to find $includeFile"
    Exit
   }
. $includeFile
} #end GetInclude

Function ParseAction()
{ 
 switch ($action)
 {
  "M" { ConvertToFeet($value) }
  "F"  { ConvertToMeters($value) }
  "C" { ConvertToFahrenheit($value) }
  "Fa" { ConvertToCelsius($value) }
  "Mi" { ConvertToKilometers($value) }
  "K"  { ConvertToMiles($value) }
  DEFAULT { "Dude illegal value." ; GetHelp ; exit }
 } #end action
} #end ParseAction

# *** Entry Point ***

If($help) { GetHelp ; exit }
if(!$action) { "Missing action" ; GetHelp ; exit }
GetInclude
ParseAction
