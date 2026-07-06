# Purpose: Get-MoreHelp — General-purpose PowerShell utilities.
﻿# Get-MoreHelp.ps1
# ed wilson, msft 11/27/2008
Function Get-MoreHelp()
{
 Get-Help $args[0] -Full | 
 more
} #end Get-MoreHelp
