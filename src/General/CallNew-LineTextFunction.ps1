# Purpose: CallNew-LineTextFunction — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE: 4/5/2009
#
# KEYWORDS: Strings, Measure-Object, Function
#
# COMMENTS: These two functions provide some basic
# text capabilities. The New-Line will create a line that is
# the length of an input text. This is helpful when you want
# a underline for separation that is sized to the text. 
# The Get-TextStats provides stats based upon an 
# input text file. 
# 
# "This is a string" | ForEach-Object  {$_ ; New-Line $_}
# Get-TextStats "This is a string"
# ------------------------------------------------------------------------
Function New-Line([string]$stringIn)
{
 "-" * $stringIn.length
} #end New-Line

Function Get-TextStats([string[]]$textIn)
{
 $textIn | Measure-Object -Line -word -char
} #end Get-TextStats

# *** Entry Point to script ***
"This is a string" | ForEach-Object  {$_ ; New-Line $_}

