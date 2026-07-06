# Purpose: splat2 — General-purpose PowerShell utilities.
$sourceComputers = "dc2","dc4"
$destinationComputers = "vmhost5","kms","clientdemo"

Test-Connection -Count 1 -ComputerName $destinationComputers -Source $sourceComputers -BufferSize 1KB




$myTestConnectionParams = @{
    count = 1
    ComputerName = $destinationComputers
    Source = $sourceComputers
    BufferSize = 1KB
}

Test-Connection @myTestConnectionParams