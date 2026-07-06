# Purpose: Get-FilesByDate — Storage management and disk operations.
﻿# -----------------------------------------------------------------------------
# Script: Get-FilesByDate.ps1
# Date:   12/30/2017
# -----------------------------------------------------------------------------
Function Get-FilesByDate
{
 Param(
  [string[]]$fileTypes,
  [int]$month,
  [int]$year,
  [string[]]$path)
   Get-ChildItem -Path $path -Include $filetypes -Recurse |
   Where-Object { 
   $_.lastwritetime.month -eq $month -AND $_.lastwritetime.year -eq $year }
  }