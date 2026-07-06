# Purpose: New-TempFile — Storage management and disk operations.
﻿# New-TempFile.ps1
# ed wilson, msft, 8/16/2009
#
# keyword: getTempFileName, io.path, out-file
# Windows PowerShell Best Practices
# -----------------------------------------------------------------------------
Function New-TempFile
{
 [CmdletBinding()]
 Param(
  [Parameter(Position=0,ValueFromPipeline=$true)]
  [PSObject[]]$inputObject
 )#end param
  $tmpFile = [io.path]::getTempFileName()
  $inputObject | Out-File -filepath $tmpFile
  $tmpFile
} #end function New-TempFile

# *** Entry Point to Script ***
 $rtn = New-TempFile  -inputObject (Get-Service)
 notepad $rtn