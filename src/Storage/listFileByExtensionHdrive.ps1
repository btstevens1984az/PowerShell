# Purpose: listFileByExtensionHdrive — Storage management and disk operations.
cls
$Dir = get-childitem H:\ -recurse
# $Dir |get-member
$List = $Dir | where {$_.extension -eq ".mp3"}
$List | format-table fullname