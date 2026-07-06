# Purpose: DPMvolumeSizingEXSG unsigned — General-purpose PowerShell utilities.
# Date   : 2/1/2008
#		
# Must run on an 222.205.193.149 2007 Server
# Collects EDB and log information and formats for import into DPM storage calculator workbook
# v0.8: using $sglist = @(....) to ensure it is an array with count property
# V0.9: pull active node name from clustered mailboxc status list when replicated
#		can no longer use simple \\59.72.65.227\path appraoch with W2008 and later
# V.091 adjusted remainder of script still based on $i counter no longer in use
  
$version="v0.91"
write-host
write-host "=> Starting collecting information $version ..." -foregroundcolor green
write-host
#
$oneGB=1024*1024*1024 		#1GB divider
$oneMB=1024*1024		#1Mb divider

#
$cms = Get-ClusteredMailboxServerStatus
$sglist=get-storagegroup		# get storage group for logfolderpath information
$mdb=get-mailboxdatabase		# get mailboxdata base for complete edb file spec


#loop through all servers
foreach ($sg in $sglist) {
	write-host -nonewline "Processing -> $sg ..."		#tell what we are doing
	#find edb path
    $dbpath=($mdb |?{($_.StoragegroupName -match $sg.Name) -and ($_.ServerName -match $sg.ServerName)}).edbfilepath.pathname	
    if ($sg.replicated -eq "None") {
		$NameToUse = $sg.ServerName
	}
	else {
		#get active node
		$cl = $cms | ? {$_.Identity -eq $sg.ServerName}
		$NameToUse = ($cl.OperationalMachines | ? {$_ -match "Active"}).Split("<")[0].trim()
	}
	$edbunc="\\"+ $NameToUse + "\"+ $dbpath
    $edbunc=$edbunc -replace(":","$")					#   ,,
    $edbsiz=(get-item $edbunc).length					# get edb size
    
	# build unc path to into collecting file info's
	$logunc="\\"+ $NameToUse + "\"+ $sg.logfolderpath + "\*.log"	
    $logunc=$logunc -replace(":","$")					   
	
	Write-Host "Getting EDB data from $edbunc"
	Write-Host "Getting LOG data from $logunc"
	
	# walk and summarize size of *.logs
	# bottom at 96/day because 222.205.193.149 2007 does at least 1 log each 15 minutes
	$t=0
    get-item $logunc | foreach-object {$t=$t + $_.length}			
	if ($t -lt (96* $oneMB))
	{
		$t = 96 * $oneMB 						
	} 

 	# get drive info's from computer and match edb drive (systemfolderpath)
	$wmi = (get-wmiobject -query "select * from win32_logicaldisk where Size > 1" -computer $sg.servername)
	$drive=$wmi | where-object {$_.DeviceID -match $sg.systemfolderpath.drivename}
	
	# check if reasons that DPM protection might fail
	$FlagReasons=""
	$FlagBad=""
	if ($drive.freespace/$oneGB -gt 1) 
	{
		$FlagReasons=$FlagReasons + $drive.DeviceID + " =<1GB "
		$FlagBad="TRUE"
	}
	# match log drive (logfolderpath) 
	$drive=$wmi | where-object {$_.DeviceID -match $sg.logfolderpath.drivename}
	if ($drive.freespace/$oneGB -gt 1) 
	{
		$FlagReasons=$FlagReasons + $drive.DeviceID + " =<1GB "
		$FlagBad="TRUE"
	} 

	# format tab separated and send to file
	$line= $FlagBad +  "`t" + $FlagReasons +  "`t" + $sg.name + "`t" + ($edbsiz/$oneGB) + "`t" + ($t/$oneMB)
        	$line >> DPMvolumeSizingEXSG.csv					 	
	write-host "`t[OK]"							
}
write-host
write-host "... finished collecting information <=" -foregroundcolor green
write-host "... Wrote output to .\DPMvolumeSizingEXSG.CSV" -foregroundcolor yellow
write-host
