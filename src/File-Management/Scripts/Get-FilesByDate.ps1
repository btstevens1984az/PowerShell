# Purpose: Get-FilesByDate — File and folder management utilities.
﻿#========================================================================
# Filename:     Get-FilesByDate.ps1
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
  } #end function Get-FilesByDate