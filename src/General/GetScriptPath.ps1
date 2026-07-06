# Purpose: GetScriptPath — General-purpose PowerShell utilities.
dir variable:
$MyInvocation.invocationname | Split-Path #works in V2
$scriptRoot = $PSCommandPath | Split-Path
$PSScriptRoot #v3 only
