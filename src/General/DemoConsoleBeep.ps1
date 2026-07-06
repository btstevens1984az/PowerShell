# Purpose: DemoConsoleBeep — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE: 4/1/2009
#
# KEYWORDS: Beep
#
# COMMENTS: This script demonstrates using the console
# beep. The first parameter is the frequency between
# 37..32767. above 7500 is barely audible. 37 is the lowest
# note it will play. 
# The second parameter is the length of time 
#
# ------------------------------------------------------------------------
#this construction creates an array of numbers from 37 to 3200
#the % sign is an alias for Foreach-Object
#the $_ is an automatic variable that refers to the current item 
#on the pipeline.
#the semicolon causes a new logical line
#the double colon is used to refer to a static method
#the $_ in the method is the number on the pipeline
#the second number is the length of time to play the beep
37..32000 | % { $_ ; [console]::beep($_ , 1) }