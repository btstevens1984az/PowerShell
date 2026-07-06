# Purpose: sortNremove — General-purpose PowerShell utilities.
$TextFile = $TextFile = "C:\MachineList.Txt" 
$NewTextFile = "C:\NewMachineList.Txt"
GC $TextFile | Sort | GU > $NewTextFile

