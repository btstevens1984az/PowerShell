<#
   .Synopsis
    Gets the version of Windows that is installed on the local computer
   .Description
    Gets the version of Windows that is installed on the local computer. This 
    is information such as Windows 7 Enterprise.
   .Example
    Get-WindowsEdition.ps1
    Displays version of windows on local computer. 
   .Inputs
    none
   .OutPuts
    [string]
    VERSION: 1.2.0 Added Help tags
             1.1.1 4/2/1009 Added link to http://www.ScriptingGuys.com
             1.1.0 4/1/2009 Modified to use regex pattern
    KEYWORDS: Windows 7 Resource Kit
   .Link
     Http://www.ScriptingGuys.com
#Requires -Version 2.0
#>


$strPattern = "version"
$text = net config workstation

switch -regex ($text) 
{
  $strPattern { Write-Host $switch.current }
}
