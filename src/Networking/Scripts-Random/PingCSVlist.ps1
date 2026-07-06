# Purpose: PingCSVlist — Network diagnostics, DNS, DHCP, and connectivity.
$names = import-csv "c:\tmp\allComputersEnabled100.csv"

foreach ($name in $names){
  if (Test-Connection -ComputerName $name -Count 1 -ErrorAction SilentlyContinue){
    Write-Host "$name,up"
  }
  else{
    Write-Host "$name,down"
  }
}