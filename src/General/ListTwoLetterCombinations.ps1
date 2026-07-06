# Purpose: ListTwoLetterCombinations — General-purpose PowerShell utilities.
﻿# ListTwoLetterCombinations.ps1
# ed wilson, msft, 11/27/2008

$letterCombinations = $null
$asciiNum = 97..122
$letters = $asciiNum | ForEach-Object { [char]$_ }
Foreach ($1letter in $letters)
{
 Foreach ($2letter in $letters)
 {
  [array]$letterCombinations += "$1letter$2letter"
 }
}
"There are " + ($letterCombinations | Measure-Object).count + " possible combinations"
"They are listed here: "
$letterCombinations