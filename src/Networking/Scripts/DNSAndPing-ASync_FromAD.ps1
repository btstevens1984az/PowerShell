# Purpose: DNSAndPing-ASync_FromAD — Network diagnostics, DNS, DHCP, and connectivity.
$TotalTime = [System.Diagnostics.Stopwatch]::StartNew()
$ADStopWatch = [System.Diagnostics.Stopwatch]::StartNew()
$SearchRoot = New-Object System.DirectoryServices.DirectoryEntry -ArgumentList "LDAP://OU=Servers,OU=AZ,DC=CHW,DC=EDU"
$Searcher = New-Object System.DirectoryServices.DirectorySearcher -ArgumentList $SearchRoot, "(objectCategory=Computer)", "name", "OneLevel"
$Searcher.PageSize = 500 # Required to get more than 1000 results
$SearcherResults = $Searcher.FindAll()
$Servers = $SearcherResults.Properties.name # Property names are case-sensitive when using .NET
$SearcherResults.Dispose() # To prevent a memory leak, you must call the Dispose method when the SearchResultCollection object is no longer needed.
$ADStopWatch.Stop()
Write-Host "Seconds to enumerate AD: $($ADStopWatch.Elapsed.TotalSeconds)"
Write-Host "Total servers: $($Servers.Count)"
# Start checking DNS
$DNSStopWatch = [System.Diagnostics.Stopwatch]::StartNew()
$Results = New-Object System.Collections.ArrayList
foreach ($Server in $Servers) {
	$Info = New-Object PSObject -Property ([Ordered]@{
		Server = $Server
		IP = ""
	})
	$Task = [System.Net.Dns]::GetHostAddressesAsync($Server)
	$Info.IP = $Task
	[void]$Results.Add($Info)
}
$DNSStopWatch.Stop()
Write-Host "Seconds to check DNS: $($DNSStopWatch.Elapsed.TotalSeconds)"
# Parse DNS results
$DNSResultsStopWatch = [System.Diagnostics.Stopwatch]::StartNew()
foreach ($Result in $Results) {
	if ($Result.IP.Result -eq $null) {
		$Result.IP = $Result.IP.Exception.InnerException.Message
	}
	else {
		$Result.IP = $Result.IP.Result -join ";"	
	}
}
$DNSResultsStopWatch.Stop()
Write-Host "Seconds to parse DNS results: $($DNSResultsStopWatch.Elapsed.TotalSeconds)"
$PingStopWatch = [System.Diagnostics.Stopwatch]::StartNew()
# Start pinging
foreach ($Result in $Results) {
	$IPs = $Result.IP.Split(";")
	if (($IPs[0] -as [IPAddress]) -as [Bool]) {
		$Pings = @()
		foreach ($IP in $IPs) {
			$PingObj = New-Object System.Net.NetworkInformation.Ping
			$Pings += $PingObj.SendPingAsync([IPAddress]$IP, 200) # 200 ms timeout
			$PingObj.Dispose()
			Remove-Variable PingObj
		}
		$Result | Add-Member -NotePropertyName "Pings" -NotePropertyValue $Pings
	}
	else {
		$Result | Add-Member -NotePropertyName "Pings" -NotePropertyValue "N/A"
	}
	Remove-Variable IPs
}
$PingStopWatch.Stop()
Write-Host "Seconds to start pinging: $($PingStopWatch.Elapsed.TotalSeconds)"
# Parse ping results
$PingResultsStopWatch = [System.Diagnostics.Stopwatch]::StartNew()
foreach ($Result in $Results) {
	if ($Result.Pings -ne "N/A") {
		$Result.Pings = $Result.Pings.Result.Status -join ";"
	}
}
$PingResultsStopWatch.Stop()
Write-Host "Seconds to parse ping results: $($PingResultsStopWatch.Elapsed.TotalSeconds)"
$CSV = $Results | ConvertTo-Csv -NoTypeInformation
if ([System.IO.Directory]::Exists("C:\Temp") -eq $false) {[System.IO.Directory]::CreateDirectory("C:\Temp")}
[System.IO.File]::WriteAllLines("C:\Temp\PingResults.csv", $CSV)
$TotalTime.Stop()
Write-Host "Total time in seconds: $($TotalTime.Elapsed.TotalSeconds)"
