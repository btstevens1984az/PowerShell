# Purpose: Get-WmiClass2 — PowerShell automation.
﻿# Get-WmiClass2.ps1
# ed wilson, msft, 11/26/2008

Function Get-WmiClass([string]$ns, [string]$class)
{
 #.Help Get-WmiClass -ns "root\cimv2" -class "Processor"
 
 Get-WmiObject -List -Namespace $ns |
 Where-Object { $_.name -match $class }
} #end Get-WmiClass