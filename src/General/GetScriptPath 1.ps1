# Purpose: GetScriptPath 1 — General-purpose PowerShell utilities.
dir variable:
$scriptRoot = $PSCommandPath | Split-Path
$PSScriptRoot #v3 only
$PSCommandPath