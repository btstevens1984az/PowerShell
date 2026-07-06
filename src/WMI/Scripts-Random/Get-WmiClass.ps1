# Purpose: Get-WmiClass — PowerShell automation.
﻿
Function Get-WmiClass()
{
 #.Help Get-WmiClass "root\cimv2" "Processor"
 $ns = $args[0]
 $class = $args[1]
 Get-WmiObject -List -Namespace $ns |
 Where-Object { $_.name -match $class }
} #end Get-WmiClass

