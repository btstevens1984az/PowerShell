# Purpose: Get-ModifiedFilesUsePipeline2 — Storage management and disk operations.
# ---------------------------------------------------------------------------
# Get-ModifiedFilesUsePipeline.ps1
# ed wilson, msft
# 7/9/2009
# 
# --------------------------------------------------------------------------
Param(
    $path = "D:\",
    $days = 30
) #end param


$changedFiles = $null
$dteModified= (Get-Date).AddDays(-$days)
$changedFiles = Get-ChildItem -path $path -recurse |
where-object { $_.LastWriteTime -ge $dteModified }

"The $path has $($changedFiles.count) modified files since $dteModified"
