# Purpose: Get-FilesByDateV2 — Storage management and disk operations.
﻿# -----------------------------------------------------------------------------
# Date:   12/30/2017
# -----------------------------------------------------------------------------
Function Get-FilesByDate
{
$ErrorActionPreference = "SilentlyContinue"
Clear Host
Foreach ($i in Get-Content "C$\Temp\PCnames.txt")
{
$Path = "\\$i\c$\Program Files (x86)\Hewlett-Packard\HPCA\Agent\Lib\SYSTEM\RADIA\PATCH\ZSERVICE\"
Get-Childitem $Path | Foreach-Object{
	$ProfName = $_
	get-childitem "$Path\$ProfName\" -Filter *.EDM 
	}| out-File -append MetaDataReport.txt}
}