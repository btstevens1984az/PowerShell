# Purpose: Show-EnumerationValues — General-purpose PowerShell utilities.
# View all of the representations of the enumeration 
# by converting the value to Integer, Hexadcimal and Binary data

[Enum]::GetValues([System.IO.FileAttributes]) | 
Select-Object @{n="String";e={$_}}, `
@{n="Integer";e={[int]$_}}, `
@{n="Hexadecimal";e={[Convert]::ToString([int]$_, 16)}}, `
@{n="Binary";e={[convert]::Tostring([int]$_, 2)}} | 
Format-Table -Autosize
