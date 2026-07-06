# Purpose: Get-BulletinStatusReport — Security auditing and compliance checks.
Function Get-BulletinStatusReport {
# CSV variables
$csvfile = "C:\Users\$env:USERNAME\Desktop\Radia\BulletinStatusReport.csv"
$csvdelimiter = "`t"
$firstRowColumns = $false
 
# Do it
$dt = New-Object System.Data.Datatable
$reader = New-Object System.IO.StreamReader $csvfile
$columns = (Get-Content $csvfile -First 1).Split($csvdelimiter)
 
foreach ($column in $columns) {
 if ($firstRowColumns -eq $true) { 
 [void]$dt.Columns.Add($column)
 $reader.ReadLine()
 } else { [void]$dt.Columns.Add() }
}
 
# Read in the data, line by line
while (($line = $reader.ReadLine()) -ne $null)  {
 [void]$dt.Rows.Add($line.Split($csvdelimiter))
} 
 
$dt.rows | format-table -AutoSize -Wrap -HideTableHeaders
}