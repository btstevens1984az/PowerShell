# Purpose: ADD Patch GROUP — Windows Update and patch management.
<#
    Written by : Lance Lutt
	Updates : 04/24/2013 - Added Write-log function.
#>
## GLOBALS ##
    Import-Module ActiveDirectory

    #$ErrorActionPreference = "SilentlyContinue" 
    $scriptPath = split-path -parent $MyInvocation.MyCommand.Definition #get directory of the script.
    $log = $scriptPath + "\History.log"
## END GLOBALS ##

## FUNCTIONS ##

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
				[string]$LogPath=""
				
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
		End { $datetime=0;$Message=0;}
			
	}
function Get-HPCAReport
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
	        #[string] $instacne     = "RCA_CORE"
	        [string] $db       = "RCA_CORE"
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

function Add-HPCAPatch
    {
       
        [CmdletBinding()]
        Param
            (
                [Parameter(Mandatory=$True,ValueFromPipeline=$true)]
                [AllowEmptyString()]
                [string[]]$Computername,
                [ValidateNotNullOrEmpty()]
              #  [ValidateSet("SJMC","SRS","SRD","SRM")]
                [String]$Site
            )#End Of Param

       
      
        #GETTING AD PATH FOR THE GROUPS NEEDED
        $Desktop_Patch_Variance =  (Get-AdGroup "Desktop Patching Variance").DistinguishedName
        $PATCH_GROUP = (Get-ADGroup "HPCA_$($Site)_PATCH").DistinguishedName

        Write-Log "Variance Group : $Desktop_Patch_Variance" -LogPath $log
        Write-Log "Patch Group    : $Patch_group" -LogPath $log
        $ERRORLOG = $scriptPath + "\" + $MyInvocation.MyCommand.Name + ".log"
     
        $success_count = 0
        $failed_count = 0
        foreach ($computer IN $Computername)
        {
	        try
		        {
                   if ($computer -ne "")
                    {
                       #Write-Log $computer
                       $ocomputer = Get-ADComputer $computer -Properties MemberOf
    #                   $ocomputer.Name
    #                   $ocomputer.MemberOf
                       #Do if not member of Patch Group
                        if ($ocomputer.Memberof -notcontains $PATCH_GROUP -and $ocomputer.MemberOf -notcontains $Desktop_Patch_Variance)
			               {
                               #Do if not member Desktop Patch Variance
                               
                                        #had to break of up the if statements for some reason it will break
                                        Add-ADGroupMember -Identity $PATCH_GROUP -Members $ocomputer.DistinguishedName
			                            $success_count++ #add count of   
                            }
                        else
                            {

                                if ($ocomputer.MemberOf -contains $desktop_Patch_Variance)
                                    {
										Write-log "$computer in : $Desktop_Patch_Variance" -LogPath $log
                                    }
                            }
                        
                    }
		        }
	        catch
		        {
			        $failed_count++ #add count of 1
			        Write-log  "$computer : $_.Exception.Message " -LogPath $log -Status Error
		        }
        }
        write-log "Success: $success_count" -LogPath $log
        write-log "Failed : $failed_count" -logpath $log
       
    }
## END FUNCTIONS

## VARS ##

## END VARS ##
Write-log "************************************************" -LogPath $log
Write-Log "Starting process"  -logPath $log
Write-Log "Date : $(get-date)"  -logPath $log
Write-Log "************************************************" -logPath $log

Write-Log "Importing Enterprise Information" -logPath $log
$ent_patch = ("{0}\{1}" -f $scriptPath, "ent_patch_list.csv") #file that contains 
$oEnt_list = Import-Csv $ent_patch

Write-log "Enumerating Listing" -LogPath $log

foreach ($Ent in $oEnt_list)
    {
        try
            {
                [string]$query=$Ent.query
                [string]$location = $Ent.location

                #this point run query againt database then list insert those that are not group which will be HPCA_$location_PATCH
                Write-Log "Running query" -LogPath $log
                $devices=Get-HPCAReport -query $query | foreach-object {$_.devicename } 
       
                [int]$deviceCount=($devices | Measure-Object).Count
                
                #As long its not equal to zero then we have data.
                if ($deviceCount -ne 0)
                    {
                        Write-Log "===================================" -LogPath $log
                        Write-Log "Site  : $location" -LogPath $log
                        Write-Log "Query : $query " -LogPath $log
                        Write-Log "Query Return $deviceCount" -LogPath $log
						<# 
						#keeping for reference
                        $cDevice = New-Object System.Collections.ArrayList
                        $cDevice.Addrange($devices)
                        $cDevice.remove("")
                        $cDevice.Copyto($devices)
						#>
                        Add-HPCAPatch -Computername $devices -SITE $location 
                        Write-Log "===================================" -LogPath $log
                    }
                else
                    {
                        Write-Log "Query Return nothing" -LogPath $log -Status Warning
                    }         
                #Add-HPCAPatch -Computername 
            }
        catch
            {
                Write-Log "$_.Exception.Message " -LogPath $log -Status Error;Continue
            }
    }
	
Write-log "************************************************" -LogPath $log
Write-Log "Date : $(get-date)"  -logPath $log
Write-Log "Completed"  -logPath $log
Write-Log "************************************************" -logPath $log


#END OF SCRIPT