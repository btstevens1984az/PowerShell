# Purpose: CheckNumberRange — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE: 5/16/2009
#
# KEYWORDS: Param statement, check command
# line arguments, boundary check
# COMMENTS: This script ensures the value of the 
# command line argument is within the range of 1-5.
#
#
# ------------------------------------------------------------------------
Param($number)

Function Check-Number($number)
{
 if($number -ge 1 -And $number -le 5)
  {  $true }
 Else
  { $false }
} #end check-number

Function Set-Number($number)
{
 $number * 2
} #end Set-Number

# *** Start of script ***
If(Check-Number($number))
  { Set-Number($number) }
Else
  { '$number is out of bounds' }