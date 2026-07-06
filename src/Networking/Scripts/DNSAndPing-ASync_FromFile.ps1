# Purpose: DNSAndPing-ASync_FromFile — Network diagnostics, DNS, DHCP, and connectivity.
[void][reflection.assembly]::LoadWithPartialName("System.Windows.Forms")
$FileDialog = New-Object System.Windows.Forms.OpenFileDialog
$FileDialog.Title = "Please select a file"
$FileDialog.InitialDirectory = "U:\"
$FileDialog.Filter = "Text files (*.txt)|*.txt"
$FileDialogResult = $FileDialog.ShowDialog()
if ($FileDialogResult -eq "OK") {
       $FilePath = $FileDialog.FileName
}
else {
       exit
}
$Servers = [System.IO.File]::ReadAllLines($FilePath) | ForEach-Object {$_.Trim()} | Where-Object {[String]::IsNullOrEmpty($_) -eq $false} | Select-Object -Unique
Write-Host "Total servers: $($Servers.Count)"
# Start checking DNS
$TotalTime = [System.Diagnostics.Stopwatch]::StartNew()
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
			$Pings += $PingObj.SendPingAsync([IPAddress]$IP, 300) # 300 ms timeout
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
Pause
