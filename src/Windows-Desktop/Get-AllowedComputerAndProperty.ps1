# Purpose: Get-AllowedComputerAndProperty — Windows desktop configuration and management.
# ------------------------------------------------------------------------
# DATE:
#
# KEYWORDS: template
#
# COMMENTS: This is a parameter script template
#
#
#
#
# ------------------------------------------------------------------------
Param([string]$computer = $env:computername,[string]$property="nam")

Function Get-AllowedComputer([string]$computer, [string]$property)
{
 $servers = Get-Content -path c:\fso\serversAndProperties.txt 
 $s = $servers -contains $computer
 $p = $servers -contains $property
 Return $s -and $p
} #end Get-AllowedComputer function

# *** Entry point to Script ***

if(Get-AllowedComputer -computer $computer -property $property)
 {
   Get-WmiObject -class Win32_Bios -Computer $computer | 
   Select-Object -property $property
 }
Else
 {
  "Either $computer is not an allowed computer, `r`nor $property is not an allowed property"
 }