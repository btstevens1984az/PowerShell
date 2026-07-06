# Purpose: Get-WMINameSpace — Reusable PowerShell function libraries.
﻿Function Get-WmiNameSpace
{
 Param(
  $nameSpace = "root",
  $computer = "localhost"
 )
 Get-WmiObject -class __NameSpace -computer $computer `
 -namespace $namespace -ErrorAction "SilentlyContinue" |
 Foreach-Object `
 -Process `
   { 
     $subns = Join-Path -Path $_.__namespace -ChildPath $_.name
     if($subns -notmatch 'directory') {$subns} 
     $namespaces += $subns + "`r`n"
     Get-WmiNameSpace -namespace $subNS -computer $computer
   } 
}