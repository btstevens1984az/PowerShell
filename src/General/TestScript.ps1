<#
.SYNOPSIS
    This script runs things.
.DESCRIPTION
    .
.PARAMETER Param1
    The path to the parameter 1.
.PARAMETER Param2
    This is actually parameter 2.
#>

Param (
	[Parameter(Mandatory=$true, HelpMessage="This is parameter1")]
	[Alias("Parameter1")]
	[String]
	$Param1,
	[ValidateSet('string1','string2','string3')]
	[String]
	$Param2,
	[String[]]
	$Param3,
	[Double]
	$Param4,
	[alias("p5")]
	[ValidateRange(2,7)]
	[int]
	$Param5,
    [switch]
    $Param6,
    [bool]
    $Param7
)

Write-Output "$($Param1),$($Param2),$($Param3),$($Param4),$($Param5)"
if ($Param6) {
    Write-Output "Param6"
}
if ($Param7) {
    Write-Output "Param7"
}
