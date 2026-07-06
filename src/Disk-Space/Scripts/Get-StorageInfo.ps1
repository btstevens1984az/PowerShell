# Purpose: Get-StorageInfo — Disk space monitoring and reporting.
<#	
	===========================================================================
     Created with: SAPIEN Technologies, Inc., PowerShell Studio 2012 v3.1.34
     Created on:   01/20/2018
	 Filename:     Get-StorageInfo.ps1
	===========================================================================
	.DESCRIPTION
		Uses the Microsoft.Storage.Vds API to pull storage info from a server.
#>
#Requires -version 3

#$VerbosePreference = 'Continue'
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
$Servers = Read-Host -Prompt "Enter servers [seperated by a comma, if multiple] OR`nType `"file`" to point to a file with names OR`nJust press Enter to exit"
if ($Servers -eq "") { exit }
elseif ($Servers -eq "file") {
	$FileDialog = New-Object System.Windows.Forms.OpenFileDialog
	$FileDialog.Title = "Please select a file"
	$FileDialog.InitialDirectory = "U:\"
	$FileDialog.Filter = "Text files (*.txt)|*.txt"
	$Result = $FileDialog.ShowDialog()
	if ($Result -eq "OK") {
		$FilePath = $FileDialog.FileName
		$Servers = Get-Content $FilePath | ForEach-Object { $_.Trim() } | Where-Object { [String]::IsNullOrWhiteSpace($_) -eq $false } | Select-Object -Unique
	}
	else { exit }
}
else {
	$Servers = $Servers.Split(",").Trim()
}
$messagetitle = "Interactive?"
$message = "Do you want the script to run interactively and display GridViews of the results?`n`nIf you select Yes and have specified multiple servers, the script will not proceed to the next server unless you close the GridView window."

$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
				  "Runs script in interactively."

$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
				 "Runs script without requiring further interaction."

$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

$result = $host.ui.PromptForChoice($messagetitle, $message, $options, 0)
if ($Result -eq 1) {$NonInteractive = $true}

$messagetitle = "Raw data?"
$message = "Do you want the data displayed in friendly/readable format?`n`nIf you select Yes, the data will be prepresented with GB, MB, or TB added, like 15.01 GB.`nIf you select No, the data will be represented in raw bytes without conversion."

$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
				  "Outputs data after converting to MB/GB/TB."

$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
				 "Outputs raw data in bytes."

$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

$result = $host.ui.PromptForChoice($messagetitle, $message, $options, 0)
if ($Result -eq 1) { $RawData = $true }

Filter ConvertTo-KMG
{
	<#
	.Synopsis
	Converts byte counts to Byte\KB\MB\GB\TB\PB format
	.DESCRIPTION
	Accepts an [int64] byte count, and converts to Byte\KB\MB\GB\TB\PB format
	with decimal precision of 2
	.EXAMPLE
	3000 | convertto-kmg
	#>
	$bytecount = $_
	if ($bytecount -le 0) {return "0 Bytes"}
	switch ([Math]::Truncate([Math]::Log($bytecount,1024)))
	{
	    0 {"$bytecount Bytes"}
	    1 {"{0:n2} KB" -f ($bytecount / 1kb)}
	    2 {"{0:n2} MB" -f ($bytecount / 1mb)}
	    3 {"{0:n2} GB" -f ($bytecount / 1gb)}
	    4 {"{0:n2} TB" -f ($bytecount / 1tb)}
	    Default {"{0:n2} PB" -f ($bytecount / 1pb)}
	}
}

Write-Verbose -Message "Attempting to load Microsoft.Storage.Vds assembly."
[void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.Storage.Vds")
Write-Verbose -Message "Creating ServiceLoader object."
$VdsServiceLoader = New-Object Microsoft.Storage.Vds.ServiceLoader

$SummaryResults = New-Object System.Collections.ArrayList
$SummaryHBAFile = "$Env:USERPROFILE\Desktop\Summary_HBA_$(Get-Date -Format MM_dd_yy_HH_mm_ss).txt"
foreach ($Server in $Servers) {
	try {
		Write-Verbose -Message "Attempting to LoadService for server $Server."
		$VdsService = $VdsServiceLoader.LoadService($Server)
		Write-Verbose -Message "Waiting for service to be ready."
		$VdsService.WaitForServiceReady()
		Write-Verbose -Message "Re-enumerating."
		$VdsService.Reenumerate()
	}
	catch [Microsoft.Storage.Vds.VdsException] {
		[void][System.Windows.Forms.MessageBox]::Show("An error occurred while attempting to load or connect to the Vds service on $Server.`nError was: $($_.Exception)`nRecommend running script from a server-class OS.`nScript will exit now.","Error", 'OK', 'Error')
		exit 1
	}
	catch {
		Write-Error "An unknown error occurred for server $Server.`nError was: $($_.Exception)"
		continue
	}
	Write-Verbose -Message "Getting HBA info."
	$HBA = $VdsService.HbaPorts | Select-Object @{Name="PortWwn";Expression={$_.PortWwn -replace "(\w{2})(\w{2})(\w{2})(\w{2})(\w{2})(\w{2})(\w{2})(\w{2})", '$1:$2:$3:$4:$5:$6:$7:$8'}},
	Type,Status,PortSpeed | Format-Table -AutoSize | Out-String
	if ($HBA -eq "") {
		Write-Warning -Message "$Server does not have any HBAs"
	}
	else {
		$HBA = $Server + $HBA
		Write-Output $HBA
		$HBAFilePath = "$Env:USERPROFILE\Desktop\$($Server)_HBA_$(Get-Date -Format MM_dd_yy_HH_mm_ss).txt"
		Write-Verbose -Message "Writing HBA info to file."
		[System.IO.File]::WriteAllLines($HBAFilePath, $HBA)
		if ($Servers.Count -gt 1) {
			Write-Verbose -Message "Appending HBA info to summary file."
			[System.IO.File]::AppendAllLines($SummaryHBAFile, [String[]]$HBA)
        }
		Write-Host -ForegroundColor 'Cyan' -Object "HBA info written to $HBAFilePath"
	}
	Write-Verbose -Message "Gathering volumes."
	$Volumes = $VdsService.Providers.Packs.Volumes
	$Results = New-Object System.Collections.ArrayList
	foreach ($Volume in $Volumes) {
		$Disk = $Volume.Pack.Disks | Select-Object *
		$FreeSpace = $Volume.AvailableAllocationUnits * $Volume.AllocationUnitSize
		$Size = $Volume.Size
		if ($FreeSpace -eq 0 -or $FreeSpace -eq $null) {$PercentageFree = 0}
		else {$PercentageFree = [Decimal]::Round(($FreeSpace / $Size) * 100, 2)}
		$DiskAddress = $Disk.DiskAddress
		$UsedSpace = $Size - $FreeSpace
		if ($RawData) {
			$ConvertedSize = $Size
			$ConvertedFree = $FreeSpace
			$ConvertedUsed = $UsedSpace
        }
		else {
			$ConvertedSize = $Size | ConvertTo-KMG
			$ConvertedFree = $FreeSpace | ConvertTo-KMG
			$ConvertedUsed = $UsedSpace | ConvertTo-KMG
        }
		$Info = New-Object PSObject -Property ([Ordered]@{
			Server = $Server
			Status = $Volume.Status
			Health = $Volume.Health
			TransitionState = $Volume.TransitionState
			AllocationUnitSize = $Volume.AllocationUnitSize
			Size = $ConvertedSize
			FreeSpace = $ConvertedFree
			UsedSpace = $ConvertedUsed
			PercentageFree = $PercentageFree
			FileSystemType = $Volume.FileSystemType
			PartitionStyle = $Disk.PartitionStyle
			BusType = $Disk.BusType
			Signature = $Disk.Signature.ToString()
			DiskGuid = $Disk.DiskGuid
			AccessPath = $Volume.AccessPaths[0]
			Label = $Volume.Label
			DiskAddress = $DiskAddress
			Lun = [Int]$DiskAddress.Substring($DiskAddress.IndexOf('Lun')).Replace('Lun','')
		})
		# [Int] for LUN allows the GridView to properly sort the LunID column
		[Void]$Results.Add($Info)
		[Void]$SummaryResults.Add($Info)
	}
	$CSVFilePath = "$Env:USERPROFILE\Desktop\$($Server)_CSV_$(Get-Date -Format MM_dd_yy_HH_mm_ss).csv"
	$CSV = $Results | ConvertTo-Csv -NoTypeInformation
	Write-Verbose -Message "Writing data to CSV."
	[System.IO.File]::WriteAllLines($CSVFilePath, $CSV)
	Write-Host -ForegroundColor 'Cyan' -Object "Storage info written to $CSVFilePath"
	if (-not $NonInteractive) {
		Write-Verbose -Message "-NonInteractive switch not specified. Displaying results in interactive GridView"
		$Results | Out-GridView -Wait
	}
}
if ($Servers.Count -gt 1) {
	$SummaryCSVFilePath = "$Env:USERPROFILE\Desktop\Summary_CSV_$(Get-Date -Format MM_dd_yy_HH_mm_ss).csv"
	$SummaryCSV = $SummaryResults | ConvertTo-Csv -NoTypeInformation
	Write-Verbose -Message "Writing summary data to CSV."
	[System.IO.File]::WriteAllLines($SummaryCSVFilePath, $SummaryCSV)
	Write-Host -ForegroundColor 'Cyan' -Object "Summary storage info written to $SummaryCSVFilePath"
	Write-Host -ForegroundColor 'Cyan' -Object "Summary HBA info written to $SummaryHBAFile"
	$SummaryResults | Out-GridView -Wait
}
Pause