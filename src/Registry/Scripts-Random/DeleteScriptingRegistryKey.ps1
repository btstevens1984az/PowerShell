# Purpose: DeleteScriptingRegistryKey — Windows registry read and write operations.
# ------------------------------------------------------------------------
# DATE: 1/26/2009
#
# KEYWORDS: Registry, Remove-Item, Recurse
#
# COMMENTS: This script Deletes a couple of registry
# keys and the registry property scriptname.
#
#
#
# ------------------------------------------------------------------------

Remove-Item -Path HKCU:\Scripting -Recurse
#New-ItemProperty -Path HKCU:\Scripting\Logon -Name ScriptName -Value "Temp"
