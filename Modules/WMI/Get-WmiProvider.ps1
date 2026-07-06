# Purpose: Get-WmiProvider — Reusable PowerShell function libraries.
﻿Function Get-WmiProvider
{
 Param(
  $nameSpace = "root\cimv2",
  $computer = "localhost"
 )
  Get-WmiObject -class __Provider -namespace $namespace | 
  Sort-Object -property Name | 
  Select-Object name
}
