# Purpose: TextFunctions1 — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE: 4/5/2009
#
# KEYWORDS: Strings, Measure-Object, Function
# VERSION 2.0
#         4/5/2009 added help to the functions
# COMMENTS: These two functions provide some basic
# text capabilities. The New-Line will create a line that is
# the length of an input text. This is helpful when you want
# an underline for separation that is sized to the text. 
# The Get-TextStats provides stats based upon an 
# input text file. 
# 
#Requires -Version 2.0
# ------------------------------------------------------------------------
Function New-Line([string]$stringIn)
{
 <#
   .Synopsis
    Creates an underline the length of the input string
   .Description
    Creates an underline the length of the input string
    This is helpful when you want an underline for separation 
    purposes that is sized to the text
   .Parameter stringIn
    Input string passed when calling the function
   .Example
    "This is a string" | ForEach-Object  {$_ ; New-Line $_}
    Produces the following output:
    This is a string
    ________________
   .Example
    Get-WmiObject -Class Win32_bios -computerName 203.107.85.231,berlin | 
    Foreach-Object { $_.Path.Server ; New-Line $_.Path.Server ; $_ }
    Writes the name of each server and underlines it prior to displaying
    the default Bios information for each server.
   .Inputs 
    [String]
   .Outputs
    [String]
    Name: New-Line
    Book: Windows PowerShell Best Practices, Microsoft Press, 2009
    Version: 1.0
    Date: 4/5/2009
  .Link
   Get-WmiObject
   Foreach-Object
   Http://www.ScriptingGuys.Com
 #>
 "-" * $stringIn.length
} #end New-Line

Function Get-TextStats([string[]]$textIn)
{
 <#
   .Synopsis
    Provides stats based upon an input text file
   .Description
    Provides stats based upon an input text file. Information 
    includes number of lines, number of words and number of characters
    This makes the Measure-Object cmdlet easier to use when measuring
    text input
   .Parameter textIn
    Input string passed when calling the function
   .Example
    Get-TextStats "This is a string"
    Produces the following output:
              Lines               Words          Characters Property
              -----               -----          ---------- --------
                  1                   4                  16

   .Example
    Get-TextStats (Get-Content C:\fso\iputput.txt)
    Reads content of text file, then produces text statistics. 
   .Inputs 
    [String]
   .Outputs
    [String]
    Name: Get-TextStats
    Book: Windows PowerShell Best Practices, Microsoft Press, 2009
    Version: 1.0
    Date: 4/5/2009
  .Link
   Measure-Object
   Http://www.ScriptingGuys.Com
 #>
 $textIn | Measure-Object -Line -word -char
} #end Get-TextStats

