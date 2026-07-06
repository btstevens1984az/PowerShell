# Purpose: GetPsVersionRR — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE: 10/15/2008
#
# KEYWORDS: Registry, COM, WshShell
#
# COMMENTS: This is a parameter script template
#
#
#
#
# ------------------------------------------------------------------------

$path = "HKLM\SOFTWARE\Microsoft\PowerShell\1\PowerShellEngine"
$WshShell = New-Object -ComObject Wscript.Shell
$WshShell.RegRead("$path\RunTimeVersion")