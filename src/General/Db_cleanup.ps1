# Purpose: Db cleanup — General-purpose PowerShell utilities.
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition #get directory of the script.
$log = $scriptPath + "\History.log"
#  PROPERTIES
#how many days to keep until to delete.
[int] $DAYS=15
[string] $QUERY="Select dc.devicename as name,mtime as lastscan FROM hpca_core.dbo.deviceconfig dc where dc.mtime < DATEADD(dd,-$DAYS,sysdatetime()) and dc.devicename not like '%-FSS-%'"

#  End Properites
function Write-Log
	{
		[CmdletBinding()]
		Param
			(
				[Parameter(Mandatory=$True,ValueFromPipeline=$true)]
                [ValidateNotNullOrEmpty()]
                [string]$Message,
				[ValidateSet("Normal","Warning","Error")]
				[string]$Status="Normal",
				[string]$LogPath="",
                [int]$Prompt=0
				
			)
		Begin 
			{
				$datetime = Get-Date
				[int]$NoRedirect=1 #Set it to True by Default
				[string]$output
				if ([string]::IsNullOrEmpty($logPath)){$NoRedirect=0}
			}
		
		Process
			{	
				Switch ($Status)
					{
						{$_ -eq "Normal"}
							{
								$output = ("{0} === {1}" -f $datetime,$Message) 
							}
						{$_ -eq "Warning"}
							{
								$output = ("{0} ?== {1}" -f $datetime,$Message) 
							}
						{$_ -eq "Error"}
							{
								$output = ("{0} !== {1}" -f $datetime,$Message) 
							}
					
					}
				if ($NoRedirect -eq "0") { $output }
				else { 	$output | Out-File -Append -FilePath $LogPath }
			}
		End {$datetime=0;$Message=0;}
			
	}
function Get-HPCADB
    {
        
        [CmdletBinding()]
        Param
            (
                [ValidateNotNullOrEmpty()]
                [String]$query
                
            )#End Of Param

        #Write-Log $query -LogPath $log
        #region "imports"
	        #$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition #get directory of the script.
	        #$Log = $scriptPath + "\get-Report_Error.log" #Where the errors go
	        #$target_file = $scriptPath + "hp" #Status log.
        #endregion

        #region "VARS"
	        [string] $hostname = "114.148.18.125"
	        #[string] $instacne     = "HPCA_PATCH"
	        [string] $db       = "HPCA_CORE"
	        [string] $user     = "hpcaapp"
	        [string] $pass     = "HPCL13nt@dM1n"
	        [string] $cnnstr   = ("Server={0};Database={1};User ID={2};Password={3}" -f $hostname,$db,$user,$pass)
        #endregion


        #region "DB Connect"
        $sCnn = New-Object System.Data.SqlClient.SqlConnection
        $sCnn.ConnectionString = $cnnstr #passing the connection string

        $sCmd = New-Object System.Data.SqlClient.SqlCommand
        $sCmd.CommandText = $query
        $sCmd.Connection  = $sCnn
        $adapter = new-object System.Data.SqlClient.SqlDataAdapter
        $adapter.SelectCommand= $sCmd
        $set = New-Object System.Data.DataSet
        $adapter.fill($set)
        $sCnn.Close()
       
        $set.Tables[0]

        #endregion
   }

function Remove-HPCADB
    {
        PARAM
            (
               [Parameter(Mandatory=$True)][string]$Computername
            )
            #"DELETE FROM deviceconfig where device_id in [list of devices selected]"
            #"DELETE FROM rcaWindowsComputerUsers where ComputerName in"
            #"EXEC DELETE_HPPATCH_DEVICE [name of the device]"
        $rq="DELETE FROM  hpca_core.dbo.deviceconfig where device_id = '$Computername'; `n"
        $rq+="DELETE FROM  hpca_core.dbo.rcaWindowsComputerUsers where ComputerName = '$Computername'; `n"
        $rq+="EXEC  hpca_patch.dbo.DELETE_HPPATCH_DEVICE '$Computername'; `n"
       
        HPCADB -query $rq
    }
  
  $start_time = "StartTime : $(Get-Date -format F)" 
  write-log "*******************************************************" -logpath $log
  write-log $start_time -LogPath $log 
  write-log "*******************************************************" -logpath $log

  # Will retrieve listing of devices
  $DB= HPCADB -query $QUERY
  [int]$count = ($DB | Measure-Object).Count 
  #write-log "$count will be removed"
 
  [int]$count = 0
 
  Foreach ($oDB in $DB)
    {
        Try
            {
                
                if (($oDB.name | Measure-Object -Character).Characters -gt 0)
                    {
                        #leaving this i wanted to use for testing.  
                        if ($count -eq  7000)
                            {
                                write-log "*******************************************************" -logpath $log
                                write-log "Stop Time Exceeded Count: $(Get-Date -format F)"  -LogPath $log 
                                write-log "*******************************************************" -logpath $log
                                exit 0
                            }
                        $rc = Test-Connection -computername $oDB.name -Count 1 -ErrorAction stop;
                        write-log ("Online : {0} : {1} : {2}" -f $odb.name , $odb.lastscan, $rc.IPV4Address) -Status Warning -LogPath $log
                        #$db_rc=Remove-HPCADB -Computername $oDB.name
                        #Write-Log ("DELETED {0} : {1}" -f $odb.name,$db_rc) -LogPath $log

                    }
            }
        catch [System.Management.Automation.ActionPreferenceStopException]            
                {            
                    
                    try { throw $_}
                     
                    catch [System.Net.NetworkInformation.PingException] 
                    {
                 
                        write-log ("Offine : {0} " -f $odb.name,$odb.lastscan) -LogPath $log
                        $db_rc=Remove-HPCADB -Computername $oDB.name
                        Write-Log ("DELETED {0} : {1}" -f $odb.name,$odb.lastscan) -LogPath $log
                    }    
                    catch
                        {
                            Write-Log ("Catch Exception : {0}" -f $_) -LogPath $log -Status Error
                        }
                }
        Finally
            { 
                $count++ 
            }
        ###Do the work where###
        #write-host  $oDB.name 
    }

write-log "*******************************************************" -logpath $log
write-log "Stop Time : $(Get-Date -format F)"  -LogPath $log 
write-log "*******************************************************" -logpath $log