# Purpose: Test-ConnectionCSVlistParallel — General-purpose PowerShell utilities.
$kk20 = Import-Csv c:\tmp\comps20.csv
$kk20.Count
Measure-Command -Expression {
foreach -parallel ($comp20 in $kk20){
Test-Connection -ComputerName $comp20 -Count 1 -ErrorAction SilentlyContinue
}
	}
