# Purpose: Test-ConnectionCSVlist — General-purpose PowerShell utilities.
$kk = Import-Csv c:\tmp\comps.csv
$kk.Count
Measure-Command -Expression {
foreach ($comp in $kk){
Test-Connection -ComputerName $comp -Count 1 -ErrorAction SilentlyContinue
}
	}
