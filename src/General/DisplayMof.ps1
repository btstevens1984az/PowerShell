# Purpose: DisplayMof — General-purpose PowerShell utilities.
# --------------------------------------------------------------------
# DisplayMof.ps1
# ed wilson, msft
# 12/26/2008
#
$filepath = [io.path]::GetTempFileName()
$mof = ([wmiclass]"win32_desktop").Gettext("MOF") 
$mof = $mof -replace "\;", "`r"
$mof | Out-File -filepath $filePath -width 250
notepad $filepath
