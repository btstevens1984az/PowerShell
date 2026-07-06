# Purpose: listFileByExtension — Storage management and disk operations.
cls

$Dir = get-childitem o:\oldexcess -recurse
# $Dir |get-member
$List = $Dir | where {$_.extension -eq ".mp3"}
$List | format-table name