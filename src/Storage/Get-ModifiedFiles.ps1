# Purpose: Get-ModifiedFiles — Storage management and disk operations.
# Get-ModifiedFiles.ps1
# ed wilson
Param(
    $path = "D:",
    $days = 30
) #end param
$dteModified= (Get-Date).AddDays(-$days)
$files = Get-ChildItem -path $path -recurse 

Foreach($file in $files)
{
  if($file.LastWriteTime -ge $dteModified)
    { $changedFiles ++ }
}

"The $path has $changedFiles modified files since $dteModified"
