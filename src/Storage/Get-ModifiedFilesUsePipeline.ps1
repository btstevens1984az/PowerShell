# Purpose: Get-ModifiedFilesUsePipeline — Storage management and disk operations.
# ---------------------------------------------------------------------------
# Get-ModifiedFilesUsePipeline.ps1
# ed wilson, msft
# 7/9/2009
# 
# --------------------------------------------------------------------------
Param(
    $path = "C:\data",
    $days = 30
) #end param

$dteModified= (Get-Date).AddDays(-$days)
Get-ChildItem -path $path -recurse |
ForEach-Object {
  if($_.LastWriteTime -ge $dteModified)
    { $changedFiles ++ }
}

"The $path has $changedFiles modified files since $dteModified"