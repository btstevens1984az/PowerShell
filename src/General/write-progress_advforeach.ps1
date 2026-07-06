# Purpose: write-progress_advforeach — General-purpose PowerShell utilities.
$events = get-eventlog -logname system
$events | foreach-object -begin {clear-host;$i=0;$out=""} `
-process {if($_.message -like "*bios*") {$out=$out + $_.Message};
$i = $i+1;`
write-progress -activity "Searching Events" `
-status "Progress:" -percentcomplete ($i/$events.count*100)} `
-end {$out}