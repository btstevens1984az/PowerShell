# Purpose: copy-rename — General-purpose PowerShell utilities.
$source = "c:\folder1\*.jpg"
$target_dir = "d:\folder2"
if (!($target_dir.endswith("\"))){$target_dir += "\"}

$files = gci $source
foreach ($file in $files){
if ($file.basename -match "^(\d+)"){
    if (!(test-path ($target_dir + $matches[1]))){mkdir ($target_dir + $matches[1])}
    $newfile = $target_dir + $matches[1] + "\" + $file.basename + "_new" + $file.extension
    move-item $file.fullname $newfile
    add-content log.txt "Moved $($file.fullname) to $($newfile)"
    }

}