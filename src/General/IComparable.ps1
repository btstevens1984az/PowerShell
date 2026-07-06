# Purpose: IComparable — General-purpose PowerShell utilities.
$computers = 5..1 | %{"testsrv$_" | %{ [computerinfo]::new($_,$true,$true)}}

$computers[0].CompareTo($computers[1])
$computers | Select-Object ComputerName
#Sort-object will automatically sort using the implemented Icompareable interface.
$computers  | Sort-Object | Select-Object ComputerName

