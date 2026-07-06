# Purpose: Get-Pi — General-purpose PowerShell utilities.
#calculate PI pnemonic
# each word represents a digit by its length
$('How I wish I could calculate Pi better' -Split " " | % {[string]$a += $_.length}; $a.Insert(1,"."))