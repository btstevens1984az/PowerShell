# Purpose: copy and rename files — Storage management and disk operations.
#$files = gci c:\folder1\*.jpg
#foreach ($file in $files){
#if ($file.name -match "^(\d+)(\w+)\.jpg$"){
#if (!(test-path ("d:\folder2\" + $matches[1]))){new-item ("d:\folder2\" + $matches[1]) -type "directory"}
#$newname = $file.name.split(".")[0] + "_new." + $file.name.split(".")[1]
#move-item $file.fullname ("d:\folder2\" + $matches[1] + "\" + $newname)
#add-content log.txt "Moved $($file.fullname) to $("d:\folder2\" + $matches[1] + "\" + $newname)"

#}

#}

$files = gci c:\folder1\*.jpg
foreach ($file in $files){
if ($file.name -match "^(\d+)(\w+)\.jpg$"){
if (!(test-path ("d:\folder2\" + $matches[1]))){new-item ("d:\folder2\" + $matches[1]) -type "directory"}
$newname = $file.name.split(".")[0] + "_new." + $file.name.split(".")[1]
copy-item $file.fullname ("d:\folder2\" + $matches[1] + "\" + $newname)
}

}

#another version  checking for spaces in file name

$files = gci c:\folder1\*.jpg
foreach ($file in $files){
if ($file.name -match "^(\d+)(\s*\w+)\.jpg$"){
if (!(test-path ("d:\folder2\" + $matches[1]))){new-item ("d:\folder2\" + $matches[1]) -type "directory"}
$newname = $file.name.split(".")[0] + "_new." + $file.name.split(".")[1]
move-item $file.fullname ("d:\folder2\" + $matches[1] + "\" + $newname)
add-content log.txt "Moved $($file.fullname) to $("d:\folder2\" + $matches[1] + "\" + $newname)"

}

}


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