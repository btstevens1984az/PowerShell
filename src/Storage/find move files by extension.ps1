# Purpose: find move files by extension — Storage management and disk operations.
$Path = "C:\A\"

$List = get-childitem -path $Path -recurse *.swf | where{$_.Name -notlike "button*"}



foreach($file in $list){



$MovePath = (join-path -path 'C:\B\' -childpath $file.FullName.SubString(4))



$MoveDirectory = (join-path -path 'C:\B\' -childpath $file.DirectoryName.SubString(4))



new-item $MoveDirectory -type directory -ea SilentlyContinue

move-item -Path $file.FullName -destination $MovePath



}