# Purpose: roundingmidPoints — General-purpose PowerShell utilities.
#Interesting rounding behavior:
#http://msdn.microsoft.com/en-us/library/system.math.round(v=vs.110).aspx#Precision
#http://msdn.microsoft.com/en-us/library/system.midpointrounding(v=vs.110).aspx

[math]::round(4.5,0)
[system.math]::round(4.5,[System.MidpointRounding]::AwayFromZero)

