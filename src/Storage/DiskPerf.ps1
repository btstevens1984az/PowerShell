# Purpose: DiskPerf — Computer hardware and system inventory.
$NumSamples = 10
$Interval = 2
$lastRead = 0
$lastReadBase =0
$CurRead =0
$CurReadBase = 0
[array] $ReadValues=@()

for($i=0; $i -le $NumSamples;$i++)
{
$wmiperf = get-wmiobject Win32_PerfRawData_PerfDisk_LogicalDisk -Filter "name='c:'"
[Int64]$lastRead = $CurRead
[Int64]$lastReadBase = $CurReadBase
[Int64]$CurRead = $wmiperf.AvgDisksecPerRead
[Int64]$CurReadBase = $wmiperf.AvgDisksecPerRead_Base
[Int64]$TimeFreq = $wmiperf.Frequency_PerfTime
If ($i -gt 0)
{
	If ($CurReadBase-$lastReadBase -ne 0)
	{
	$AvgDiskRead= (($CurRead-$lastRead)/$TimeFreq)/($CurReadBase-$lastReadBase)
	Write-Host $AvgDiskRead
	$ReadValues = $ReadValues + @($AvgDiskRead)
	}
	else
	{
		Write-Host 0
		$ReadValues = $ReadValues + @(0)
	}
}
Start-Sleep $Interval

}

$ReadValues | Measure-Object -Average -Maximum -Minimum | Select-Object count,maximum,minimum,average | FL *
