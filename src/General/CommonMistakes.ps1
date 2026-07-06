# Purpose: CommonMistakes — General-purpose PowerShell utilities.
#Common Mistakes with Basic Functions

Function SUM ($a,$b)
{
    $a+$b
}

SUM(5,5) #correct would be: sum 5 5
Set-StrictMode -Version 2

Function GetOS
{
    "Getting OS"
    return (Get-WmiObject -Class Win32_OperatingSystem).caption
    "I won't get here"
}

$result = GetOS
$result
#everyting is returned. The return keyword will return the value on the right and exit the function but anything previously not captured is also returned.