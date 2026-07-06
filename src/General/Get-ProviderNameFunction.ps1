# Purpose: Get-ProviderNameFunction — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE: 7/8/2009
#
# KEYWORDS: wmi, wmi provider, functioin, wmiclass
# psbase, wmi qualifiers
# COMMENTS: This script contains a function that retrieves
# the wmi provider name from the wmi class. 
#
#
# ------------------------------------------------------------------------

Function Get-ProviderName([string]$class)
{
 ([wmiclass]"$class").psbase.qualifiers |
   Foreach-Object {
     if($_.name -eq 'Provider') { $_.value }
   }#end foreach-object
} #end Get-ProviderName function

# *** Entry point to script ***
Get-ProviderName -class "win32_NTDomain"