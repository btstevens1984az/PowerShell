# Purpose: Get-MoreHelp2 — General-purpose PowerShell utilities.
﻿# Get-MoreHelp2.ps1
# ed wilson, msft, 11/27/2008

Function Get-MoreHelp
{
 # .help Get-MoreHelp Get-Command Get-Process
 For($i = 0 ;$i -le $args.count ; $i++)
 {
  Get-Help $args[$i] -full |
  more
 } #end for
} #end Get-MoreHelp

New-Alias -name gmh -value Get-MoreHelp -Option allscope