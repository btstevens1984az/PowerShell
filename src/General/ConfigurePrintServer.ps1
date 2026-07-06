# Purpose: ConfigurePrintServer — General-purpose PowerShell utilities.
#print Server Build Script
#current version works remotely using WS-MAN with Powershell's invoke-command using Credssp.
#Set-strictmode doesn't work when calling this script using PSremoting through invoke-command (basically errors out on a $_ reference where none is explicitly specified)
#Set-StrictMode -Version 2.0
#Start-transcript is not supported when run from with in PS Remote session
#Start-Transcript C:\printserverbuildlog.txt
$ADReplicationDelaySeconds = 30
$Computername = (Get-WmiObject Win32_computersystem).name
$DriverLocation = "C:\drivers" #Local path to driver folder
$DriverShareName = "Drivers" 
$DFSLinkPath = "\\kaylos.lab\dfs\printdrivers"
$LocalSharePath = "\\$computername\$driverShareName"
$DFSRRGname = "kaylos.lab\dfs\printdrivers" #DFSR Replication Group Name
$DFSRRFName = "printdrivers"	#DFSR Replicated Folder Name
$PrimaryDFSRReplicaServer = "prn1"
Function Install-Features
{
<#
This function takes a list of feature names as input (pipeline input supported).
The function checks to see if the feature is installed and if it isn't it will install it along with all subfeatures.
If a feature requires a restart this function will restart the server.
#>
param([parameter(Mandatory=$true,ValueFromPipeline=$true)][String[]]$features)
	
	process
	{
		try
		{
			$Error.Clear()
			if (!(Get-Module ServerManager))
			{
				Import-Module ServerManager -ErrorAction Stop
			}
			Foreach ($feature in $features)
			{
				#Intial use of Get-windowsFeature can be slow
				if (!((Get-WindowsFeature $feature).installed))
				{
					$installresult = Add-WindowsFeature $feature -IncludeAllSubFeature
					If ($installresult.RestartNeeded -eq "Yes")
					{
						Restart-Computer 131.230.190.167
					}
					If ($Error)
					{
						If ($Error[0].exception -eq "Please restart the computer before trying to install more roles/features.")
						{
							Write-Debug "Need to restart before installing roles: Restarting..."
							Restart-Computer 131.230.190.167
						}
						else
						{
						 #place holder for unexpected errors
						 Write-host "Unexpected Error Encountered"
						 $Error | fl * -Force
						}				
					}
				}
			}
		}
		catch
		{
		Write-Host "generic catch"
		$Error | fl * -Force
		}
		$Error.Clear()
	}
}

#**************BEGIN MAIN*************************
<#
Check for and install Windows Features
Print-Server
FS-DFS
Printer Server role won't install as part of a startup script.
#>
$features = "Print-Server","FS-DFS"
$features | Install-Features

<#
*****************Configure DFS********************
Need to create Directory for DFS drivers folder, this could also be done via Group Policy Preferences.
#>
if (!(Test-Path $DriverLocation))
{
	mkdir $DriverLocation
}
$share = [wmiclass] "win32_share"
$share.Create($DriverLocation,$DriverShareName,0,$null,"Printer Drivers")
Invoke-Expression "dfsutil target add $DFSLinkPath $LocalSharePath"
invoke-expression "dfsradmin member new /RgName:$DFSRRGname /memname:$computername /force"
$Error.Clear()
invoke-expression "dfsradmin conn new /rgname:$DFSRRGname /SendMem:$PrimaryDFSRReplicaServer /RecvMem:$Computername /ConnEnabled:true"
#check incase dfsr membership has not replicated
if ($Error)
{
	Write-host "Error encountered creating DFSR replication object, could be due to membership not replicating. Waiting $ADReplicationDelaySeconds seconds to retry operation"
	Start-Sleep -Seconds $ADReplicationDelaySeconds
	$Error.Clear()
	invoke-expression "dfsradmin conn new /rgname:$DFSRRGname /SendMem:$PrimaryDFSRReplicaServer /RecvMem:$Computername /ConnEnabled:true"
	If ($Error)
	{
		Write-Error "Need to rerun build script, still could not create DFSR connection objects"
		$Error.Clear()
	}

}
invoke-expression "dfsradmin conn new /rgname:$DFSRRGname /SendMem:$Computername /RecvMem:$PrimaryDFSRReplicaServer /ConnEnabled:true"
invoke-expression "dfsradmin Membership Set /RgName:$DFSRRGname /RfName:$DFSRRFName /MemName:$computername /LocalPath:$DriverLocation /MembershipEnabled:true  /force"

#speed up initial sync, consider polling partner but given AD replication latency this might not provide a benefit unless a delay(start-sleep) is built in.
Start-Sleep -Seconds $ADReplicationDelaySeconds
dfsrdiag pollad
Invoke-Expression "dfsrdiag pollad /member:$PrimaryDFSRReplicaServer"
invoke-expression "dfsrdiag syncnow /partner:$PrimaryDFSRReplicaServer /rgname:$DFSRRGname /member:$computername /time:60 /v"

gpupdate /force
#******************END Configure DFS**************

#**************END MAIN***************************