# Purpose: Get-BiosMandatoryParameterWithAlias — Hardware and software inventory collection.
# ------------------------------------------------------------------------
# DATE: 5/12/2009
#
# KEYWORDS: Param, Mandatory Parameter,
# Parameter (Mandatory = $true), alias attribute
# COMMENTS: This script defines a mandatory parameter
# the parameter is an array of strings, it also uses an alias
# the #requires -version 2.0 is used because parameter
# modifiers are not allowed in 1.0
#
# ------------------------------------------------------------------------
#requires -version 2.0
Param(
    [Parameter(Mandatory = $true)]
    [alias("CN")]
    [string[]]
    $computername)

Get-WmiObject -class Win32_bios -computername $computername