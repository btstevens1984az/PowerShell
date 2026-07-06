# Purpose: Get-WmiClassWithAlias — PowerShell automation.
﻿# Get-WmiClassWithAlias.ps1
# ed wilson, msft, 11/28/2008

Function Get-WmiClass([string]$ns, [string]$class)
{
 #.Help Get-WmiClass -ns "root\cimv2" -class "Processor"
 
 Get-WmiObject -List -Namespace $ns |
 Where-Object { $_.name -match $class }
} #end Get-WmiClass
New-Alias -Name gwc -Value Get-WmiClass -Description "Mred Alias" `
-Option readonly,allscope