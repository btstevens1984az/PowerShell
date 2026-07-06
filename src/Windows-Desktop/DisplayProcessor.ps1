<#
   .Synopsis
    Displays Processor information for the computer processor.
   .Description
    This script displays processor information for the local or 
    remote computer. This includes Processor utilization, processor 
    speed, L2 cache size, number of cores, and architecture.
   .Example
    DisplayProcessor.ps1
    Displays processor information for the local computer. 
   .Example
    DisplayProcessor.ps1 -computer 157.217.58.110
    Displays Processor information for a remote computer named berlin.
   .Inputs
    [string]
   .OutPuts
    [string]
    NAME:  Windows 7 Resource Kit
    VERSION: 1.0.0
    KEYWORDS:
   .Link
     Http://www.ScriptingGuys.com
#Requires -Version 2.0
#>
param(
  [Parameter(position=0)]
  [string]
  [alias("CN")]
  $computer=$env:computername
) #end param

# Begin Functions
function New-Underline
{
<#
.Synopsis
 Creates an underline the length of the input string
.Example
 New-Underline -strIN "Hello world"
.Example
 New-Underline -strIn "Morgen welt" -char "-" -sColor "blue" -uColor "yellow"
.Example
 "this is a string" | New-Underline
 NAME:
 KEYWORDS:
.Link
 Http://www.ScriptingGuys.com
#>
[CmdletBinding()]
param(
      [Parameter(Mandatory = $true,Position = 0,valueFromPipeline=$true)]
      [string]
      $strIN,
      [string]
      $char = "=",
      [string]
      $sColor = "Green",
      [string]
      $uColor = "darkGreen",
      [switch]
      $pipe
 ) #end param
 $strLine= $char * $strIn.length
 if(-not $pipe)
  {
   Write-Host -ForegroundColor $sColor $strIN
   Write-Host -ForegroundColor $uColor $strLine
  }
  Else
  {
  $strIn
  $strLine
  }
} #end New-Underline function

Function funQueryProcessor ($computer)
{
 get-wmiobject -class win32_processor -computername $computer |
 foreach-object `
  {
   New-Underline("Processor details for $computer")
   $_.psobject.properties |
   foreach-object `
    {
     If($_.value)
      {
       if ($_.name -match "__"){}
       ELSE
        {
         $Processor +=@{ $($_.name) = $($_.value) }
        } #end else
      } #end if
    } #end foreach property
    $Processor  ; $Processor.clear()
  } #end foreach Processor
 exit
} #end funQueryProcessor
# Entry Point

funQueryProcessor -computer $computer


