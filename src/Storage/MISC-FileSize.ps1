# Purpose: MISC-FileSize — Storage management and disk operations.
$location = Read-Host "Path to search down from"
$folders = Get-ChildItem -Path $location -Recurse -Directory

$array = @()

foreach ($folder in $folders)
{
$foldername = $folder.FullName

$files = Get-ChildItem $foldername -Attributes !Directory


$size = $Null
$files | ForEach-Object -Process {
$size += $_.Length
}

 $sizeinmb = [math]::Round(($size / 1mb), 1)

$array += [pscustomobject]@{
Folder = $foldername
Count = $files.count
'Size(MB)' = $sizeinmb
}
}

Write-Output $array | Format-Table -AutoSize