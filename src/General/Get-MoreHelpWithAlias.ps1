# Purpose: Get-MoreHelpWithAlias — General-purpose PowerShell utilities.
﻿# Get-MoreHelpWithAlias.ps1
# ed wilson, msft, 11/28/2008

Function Get-MoreHelp
{
 Get-Help $args[0] -full | 
 more
} #End Get-MoreHelp
New-Alias -name gmh -value Get-MoreHelp -Option allscope
