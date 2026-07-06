# Purpose: 1 Satellite Check — HP Radia client automation and satellite servers.
## IF ERROR WONT STOP THE SCRIPT
$ErrorActionPreference = "SilentlyContinue"
#region "VARS"

	$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition #get directory of the script.
	#$Log = $scriptPath + "\script_Error.log" #Where the errors go
	$target_file = $scriptPath + "\target.txt" #Status log.
    $report_file = $scriptPath + "\Satellite_report.csv"
	
#endregion 
$Error_LEVEL=0
$satellite_list = Get-Content $target_file
#$satellite_list
$sync_path = "\E$\Hewlett-Packard\HPCA\ApacheServer\apps\console\etc\sync.pid"
$sc=@() 
foreach ($satellite in $satellite_list)
{
	Get-WmiObject -class
	$satellite_path = "\\" + $satellite + $sync_path
	[string]$syncExist=""
	[string]$errorDescription=""
	$oSatellite=New-Object PSObject
	
	try
		{
			if (Test-Path -path $satellite_path )
			{
				$sync_Exist = "YES"
			}
			else
			{
				$sync_Exist = "NO"
			}
			
		}
	catch
		{
			$Error_LEVEL=1
			$errorDescription =  "$satellite : $_.Exception.Message "
			"$satellite : $_.Exception.Message ";Continue
			
		}
     
     $oSatellite | add-member NoteProperty Target                      $satellite
	 $oSatellite | Add-Member NoteProperty SyncPID                     $sync_Exist
	 $oSatellite | Add-Member NoteProperty Error_Description           $errorDescription    
	 
     $oVolumes = Get-WmiObject -class win32_Volume -ComputerName $satellite -Filter "DriveType=3"
                    foreach($oVolume in $oVolumes)
                        {
                                $oSatellite | Add-Member $oVolume.Name   $("{0:N2}" -f ($oVolume.Freespace / 1GB))                
                                                                                
                        }
	
	     
	$sc+=$oSatellite
}
$sc | sort -Property SyncPID -Descending | Export-Csv $report_file -NoTypeInformation
#$sc | sort -Property SyncPid -Descending | ConvertTo-Html | Out-File g:\Satellite.html
#$sc | sort -Property SyncPID -Descending | Out-GridView -Title "Satellite SyncPid File Exist"
exit $ERROR_LEVEL