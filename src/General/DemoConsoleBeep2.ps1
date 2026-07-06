# Purpose: DemoConsoleBeep2 — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE: 4/1/2009
# VERSION 2.0
# 4/4/2009 cleaned up comments. Removed use of % alias. Reformatted.
#
# KEYWORDS: Beep
#
# COMMENTS: This script demonstrates using the console
# beep. The first parameter is the frequency. Allowable range is between
# 37..32767. A number above 7500 is barely audible. 37 is the lowest
# note the console beep will play. 
# The second parameter is the length of time.
#
# ------------------------------------------------------------------------

37..32000 | 
Foreach-Object { $_ ; [console]::beep($_ , 1) }