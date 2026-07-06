# Purpose: HPCA — HP Radia client automation and satellite servers.
[string] $hostname = "114.148.18.125"
[string] $db       = "RCA_CORE"
[string] $user     = "hpcaapp"
[string] $pass     = "HPCL13nt@dM1n"
	        
$sql = (get-content C:\temp\top30missing.sql)

Invoke-SqlCmd -Server $hostname -Database $db -Username $user -Password $pass -Query "$sql" | export-csv c:\temp\top30missing.csv -notypeInformation