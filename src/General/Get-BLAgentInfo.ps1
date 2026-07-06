# Purpose: Get-BLAgentInfo — General-purpose PowerShell utilities.

$ErrorActionPreference= 'SilentlyContinue'
$FilePathFix = "\\114.148.18.125\g$\BLAgentFix\"
$WordToFind= "srvadmin"
$MachineData = get-content "c:\PSDEV\BLA-check.txt"
	foreach ($ServerItem in $MachineData) 
{
		Write-Host -ForegroundColor Yellow $ServerItem " is processing now"
		Add-Content '\\114.148.18.125\UpdatesInventory$\BLServerAgents.txt' ************************
		Add-Content '\\114.148.18.125\UpdatesInventory$\BrokenServerAgents.txt' $ServerItem
# test if online		
		if ((Test-Connection -computername $ServerItem -Quiet) -eq $true) 
		{
		
# check local accounts
		# Get-WmiObject -Class Win32_UserAccount -Namespace "root\cimv2" -filter "LocalAccount='True'" -ComputerName $ServerItem | FT
		$LocalUserAccount = Get-WmiObject -Class Win32_UserAccount -Namespace "root\cimv2" -filter "Name='srvadmin'" -ComputerName $ServerItem
		
		write-host "srvadmin should be in next line - missing means the local account is Administrator"
		Add-Content '\\114.148.18.125\UpdatesInventory$\BLServerAgents.txt' "srvadmin should be in next line - missing means the local account is Administrator"
		write-host -ForegroundColor Green $LocalUserAccount.name is the Local administrator user account
		Add-Content '\\114.148.18.125\UpdatesInventory$\BLServerAgents.txt' $LocalUserAccount.name is the Local administrator user account

		
		# check path for RSC dir and dates of 177.210.68.248 file
	#if path fails - assume agent is not installed.  verify that install files are on server call install after srvadmin local account is verified.
	# if path true - check exports and 151.17.42.141 files
	
			$TestPathDir = test-path "\\$ServerItem\c$\windows\rsc"
			
			# IF path is true then write host - 
			write-host -ForegroundColor Green Windows rsc directory exists is $TestPathDir
		Add-Content '\\114.148.18.125\UpdatesInventory$\BLServerAgents.txt'  Windows rsc directory exists is $TestPathDir
		
		# compare date	LastWriteTime = 7/29/2017 else copy new exports file into directory	
		# if date is correct then check 151.17.42.141 file for srvadmin mapping
			get-item "\\$ServerItem\c$\windows\rsc\exports" |select-object Name, LastWriteTime
	
			get-item "\\$ServerItem\c$\windows\rsc\151.17.42.141" |select-object Name, LastWriteTime
			# if 151.17.42.141 exists check to see which user is mapped - it is either srvadmin or administrator
			#if itis srvadmin - nothing needs to be done.. as long as localaccount has srvadmin
			
			$fileTest = Get-Content "\\$ServerItem\c$\windows\rsc\151.17.42.141" | Select-String "srvadmin" -quiet
				
				write-host -ForegroundColor Green 151.17.42.141 has srvadmin mapped  $filetest
				Add-Content '\\114.148.18.125\UpdatesInventory$\BLServerAgents.txt' 151.17.42.141 has srvadmin mapped $filetest
				
				# Get-Content "\\$ServerItem\c$\windows\rsc\151.17.42.141" | Select-String "srvadmin" -quiet
			
			#$file = get-content "\\$ServerItem\c$\windows\rsc\151.17.42.141"
			#$containsWord = $file | %{$_ -match $wordToFind}
			#	If($containsWord -contains $true)
			#{
			#	#Add-Content log.txt $_.FullName
			#	#($file) | ForEach-Object { $_ -replace $wordToFind , $wordToReplace } | 
			#		#Set-Content $_.FullName
			#		write-host -ForegroundColor Green Local Account srvadmin was mapped on 151.17.42.141
			#}
			#	Else {
			#	write-host -ForegroundColor Red LocalAccount srvadmin not found mapped to 151.17.42.141
			#			}
			
# check for RSCDsvc service and verify it is running
				get-service -Name "RSCDsvc" -ComputerName $ServerItem | select-object Name, Status, StartType |ft
				
		
#		Get-Hotfix -ComputerName $ServerItem | Select PSComputerName, HotfixID, Description, InstalledOn, InstalledBy, Caption | export-csv -append \\114.148.18.125\UpdatesInventory$\OctoberInv-Test\October2017InventoryTest3.csv -notypeinformation
		
		}
		
		Else {
		Write-Host -ForegroundColor RED $ServerItem "NOT ONLINE"
		Add-Content '\\114.148.18.125\UpdatesInventory$\BLServerAgents.txt' $serverItem "not online"
		# Add-Content '\\114.148.18.125\UpdatesInventory$\OctoberInv-Test\serverOffline.txt' $ServerItem
			}
		
		Write-Host -ForegroundColor Yellow $ServerItem Completed 
			Add-Content '\\114.148.18.125\UpdatesInventory$\BLServerAgents.txt' $ServerItem Completed 
}

Write-Host -ForegroundColor GREEN "All systems have completed processing"
Add-Content '\\114.148.18.125\UpdatesInventory$\BLServerAgents.txt' "All systems have completed processing"