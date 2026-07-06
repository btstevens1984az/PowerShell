# Purpose: Get-FilesByDateV2 — File and folder management utilities.
﻿#========================================================================
# Filename:     Get-FilesByDateV2.ps1
Function Get-FilesByDate
{
 Param(
  [string[]]$fileTypes = @(".DOC","*.DOCX"),
  [Parameter(Mandatory=$true)]
  [int]$month,
  [Parameter(Mandatory=$true)]
  [int]$year,
  [Parameter(Mandatory=$true)]
  [string[]]$path)
   Get-ChildItem -Path $path -Include $filetypes -Recurse |
   Where-Object { 
   $_.lastwritetime.month -eq $month -AND $_.lastwritetime.year -eq $year }
  } #end function Get-FilesByDate