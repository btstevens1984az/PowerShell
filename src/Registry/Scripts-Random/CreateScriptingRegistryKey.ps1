# Purpose: CreateScriptingRegistryKey — Windows registry read and write operations.
# ------------------------------------------------------------------------
# DATE: 1/26/2009
#
# KEYWORDS: Registry, New-Item, New-ItemProperty
#
# COMMENTS: This script creates a couple of registry
# keys and sets the registry property scriptname.
#
#
#
# ------------------------------------------------------------------------

New-Item -Path HKCU:\Scripting\Logon -Value "Temp" -Force
New-ItemProperty -Path HKCU:\Scripting\Logon -Name ScriptName -Value "Temp"
