# Purpose: Get-LastBootfromSCCMCollection — Configuration Manager collections and deployments.
# Define variables
$SiteServer = 'SiteServerHostname'
$SiteCode = 'SCCMSiteCode'
$CollectionName = $env:USERNAME
# Get objects representing collections that start with $CollectionName
$Collections = Get-WmiObject -ComputerName $SiteServer -NameSpace "ROOT\SMS\Site_$SiteCode" -Class SMS_Collection -Filter "Name LIKE `"$CollectionName%`""
Write-Host "Found $($Collections.Count) collections:" -ForegroundColor 'Cyan'
$Collections | Select-Object -ExpandProperty Name
# Create ArrayList for results
$Results = New-Object System.Collections.ArrayList
# Loop through collections returned
foreach ($Collection in $Collections) {
	# Get members of each collection (server names)
	$Servers = Get-WmiObject -ComputerName $SiteServer -Namespace "ROOT\SMS\Site_$SiteCode" -Query "SELECT name FROM SMS_FullCollectionMembership WHERE CollectionID='$($Collection.CollectionID)' order by name" | Select-Object -ExpandProperty Name
	Write-Host "Found $($Servers.Count) servers in $($Collection.Name)" -ForegroundColor 'Cyan'
	# Loop through each server and get LastBoot information
	foreach ($Server in $Servers) {
		try {
			$WmiObj = Get-WmiObject -class Win32_OperatingSystem -ComputerName $Server -ErrorAction 'Stop'
			$LastBoot = [System.Management.ManagementDateTimeConverter]::ToDateTime($WmiObj.LastBootUpTime) # LastBootUpTime wmi info is in strange DMTF datetime format when returned
		}
		catch {
			$LastBoot = $_.Exception.Message.Replace("`n"," ")
		}
		try {
			$RebootPending = Invoke-WmiMethod -Class CCM_ClientUtilities -Namespace Root\CCM\ClientSDK -Name "DetermineIfRebootPending" -ComputerName $Server -ErrorAction 'Stop'
		}
		catch {
			$RebootPending = New-Object PSObject -Property @{
				IsHardRebootPending = "Error"
				RebootPending = $_.Exception.Message.Replace("`n"," ")
			}
		}
		$Object = New-Object PSObject -Property ([Ordered]@{
			Server = $Server
			CollectionName = $Collection.Name
			LastBoot = $LastBoot
			HardRebootPending = $RebootPending.IsHardRebootPending
			RebootPending = $RebootPending.RebootPending
		})
		[void]$Results.Add($Object)
	}
}
$SortedResults = $Results | Sort-Object LastBoot,CollectionName,Server
$CSV = $SortedResults | ConvertTo-Csv -NoTypeInformation
$OutputDirectory = "C:\Temp"
$FilePath = "$OutputDirectory\$CollectionName.csv"
if ([System.IO.Directory]::Exists($OutputDirectory) -eq $false) {[System.IO.Directory]::CreateDirectory($OutputDirectory)}
[System.IO.File]::WriteAllLines($FilePath, $CSV)
$SortedResults | Out-GridView
Write-Host "Results written to $FilePath" -ForegroundColor 'Cyan'
Pause