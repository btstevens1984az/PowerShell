# Purpose: MoreErrorHandling — Cross-cutting logging, error handling, and utilities.
param ([switch]$Debug,[string]$hotfixID="KB975560",[string]$filepath="servers.txt",
[switch]$help,[switch]$overwrite,[switch]$ping,[string]$OutPutDir=$PWD)

#***************BEGIN FUNCTIONS************************
Function DisplayHelp
{
	Write-Host @"
	Usage Example:
	.\ScriptName.ps1 -hotfixID "KB975560" -filePath "c:\temp\serversToCheck.txt"
	
	Parameters:
	-Debug		: Debug output enabled
	-HotfixID	: Hotfix ID to search for. Default=KB975560.
	-FilePath	: Specify a text file with a list of servers one per line. Default=servers.txt
	-overwrite	: Will overwite previous output files without prompting
	-OutPutDir	: Specify out put directory. Default = Current Directory
	-Ping		: Will ping target computer before checking patch status. This can improve performance.
	-help		: Displays this message
	
	All parameters are optional.
"@
}
#Test file and folder paths specified
Function TestPaths
{
 Write-Debug "Beginning Function: TestPaths"
 Write-Debug "Checking for input file: $filepath"
 $resultFilePath = Test-Path -Path $filepath -PathType Leaf
 If (!$resultFilePath)
 {
 	Write-host "Invalid server input file specified or default not present. See script usage below:" -ForegroundColor Red
	Displayhelp
	Write-Debug "Exiting Function TestPaths after input file check"
	exit
 }
  Write-Debug "Checking for output directory: $OutPutDir"
  $resultOutPut = Test-Path -Path $OutPutDir -PathType Container
  If (!$resultOutPut)
 {
 	Write-host "Invalid ouput directory specified or default not present. See script usage below:" -ForegroundColor Red
	Displayhelp
	Write-Debug "Exiting Function TestPaths after output directory check"
	exit
 }
 
}

#Used if -overwrite is specified to delete any preexisting log files
Function DeletePreExistingFiles
{
#OutPutFiles:$OutPutDir\Debuglog.txt,$OutPutDir\notpatched.txt,$OutPutDir\patched.txt,$OutPutDir\WMIError.txt
#			 $OutPutDir\NetworkError.txt

 $resultOutPut = Test-Path -Path $DebugFile -PathType Leaf
  If ($resultOutPut)
 {
 	Write-Debug "Deleting $DebugFile"
	Remove-Item -Path $DebugFile
 }
 
  $resultOutPut = Test-Path -Path $NotPatchedFile -PathType Leaf
  If ($resultOutPut)
 {
  	Write-Debug "Deleting $NotPatchedFile"
	Remove-Item -Path $NotPatchedFile
 }
 
  $resultOutPut = Test-Path -Path $PatchedFile -PathType Leaf
  If ($resultOutPut)
 {
  	Write-Debug "Deleting $PatchedFile"
	Remove-Item -Path $PatchedFile
 }
 
  $resultOutPut = Test-Path -Path $WmiErrorFile -PathType Leaf
  If ($resultOutPut)
 {
  	Write-Debug "Deleting $WmiErrorFile"
	Remove-Item -Path $WmiErrorFile
 }
 
  $resultOutPut = Test-Path -Path $NetworkErrorFile -PathType Leaf
  If ($resultOutPut)
 {
  	Write-Debug "Deleting $NetworkErrorFile"
	Remove-Item -Path $NetworkErrorFile
 }

}

#read server names from $filepath
Function ReadServers
{
	Write-Debug "Reading file: $filepath"
	$servers = Get-Content $filepath
	if ($servers)
	{
		#return array of servers
		$servers
	}
	else
	{
		Throw "No servers specified"
		Exit
	}

}

#Main function used to to check hotfix status
#$servers = an array of server names
Function CheckForHotFix
{param ($servers)
 	foreach ($server in $servers)
	{	
		#Test using ICMP first before attempting to detect hotfix status
		If($ping) 
		{
			If (Test-Connection -ComputerName $server -Count 2 -Quiet)
			{
				$pingStatus = $true
			}
		
			Else
			{
				$pingStatus = $false
				Write-Debug "Test-Connection Error: $server"
				$server >> $NetworkErrorFile
			}
		}
		
		if ($pingStatus -or !$ping)
		{
		#proceed for checking for hotfix
			try
			{
				#check for hotfix Status
				$HotFixResult = Get-Hotfix -ComputerName $server -ID "$hotfixid" -ErrorAction "SilentlyContinue"
				if ($HotFixResult)
				{	
					#hotfix found
					Write-Debug "hotfix is installed on $server"
					Write-Debug $HotFixResult
					$server >> $PatchedFile
					
				}
				elseif($error)
				{ 
					#if no hotfix is detected a non-terminating error is thrown. Using throw to make it a terminating error
					#so it can be handled by the corresponding catch statement.
					throw $Error[0]
				}
			}
			catch [System.Runtime.InteropServices.COMException]
			{
				#Usually an RPC error do to target not being online
				#Could also be that WMI service is disabled
				Write-Debug "Connection Error: $server"
				Write-Debug "Error exception: $($_.Exception)"
				$server >> $NetworkErrorFile
				if ($Debug)
				{
					$server >> $DebugFile
					$_ | FL * -force >> $DebugFile
				}
				$error.Clear()
			}
			catch [System.UnauthorizedAccessException]
			{
			#Access denied
				Write-Debug "Access Denied WMI Error: $Server"
				if ($Debug)
				{
					$server >> $DebugFile
					$_ | FL * -force >> $DebugFile
				}
				$server >> $WmiErrorFile
				$Error.Clear()
			}
			catch [System.Management.ManagementException]
			{
				#WMI error but not an RPC error or Access Rights Error
				#i.e. Missing class,WMI corruption,provider error
				Write-Debug "Other WMI Error: $Server"
				Write-Debug "Error exception: $($_.Exception)"
				if ($Debug)
				{
					$server >> $DebugFile
					$_ | FL * -force >> $DebugFile
				}
				$server >> $WmiErrorFile
				$Error.Clear()
			}
			catch [System.ArgumentException]
			{
				#patch not found
				Write-Debug "Hotfix not detected on: $server"
				$server >> $NotPatchedFile
				$Error.Clear()
			}
			catch
			{
				#Unexpected Error catch
				Write-Debug "Unexpected Exception on: $server"
				Write-Debug "Error exception: $($_.Exception)"
				$server >> $WmiErrorFile	
				if ($Debug)
				{
					$server >> $DebugFile
					$_ | FL * -force >> $DebugFile
				}
				throw $_
			}
			Finally
			{	
				#Reset HotfixResult to prevent false positives
				$HotFixResult = $false
			}
		}
	}	
}
#***************END FUNCTIONS************************
#***************BEGIN MAIN***************************
# Display help information if help parameter is specified
Try
{
	If ($help)
	{
		DisplayHelp
		exit
	}
	
	#Capturing current debug preference settings
	$OrginalDebugPreference = $DebugPreference
	#Setting File Path Variables
	$DebugFile = "$OutPutDir\Debuglog.txt"
	$NotPatchedFile = "$OutPutDir\notpatched.txt"
	$PatchedFile = "$OutPutDir\patched.txt"
	$WmiErrorFile = "$OutPutDir\WMIError.txt"
	$NetworkErrorFile = "$OutPutDir\NetworkError.txt"
	
	# Set Debug Preference if -Debug is specified
	If ($Debug)
	{
		$DebugPreference = "Continue"
	}
	
	If ($overwrite)
	{
		Write-Debug "Overwrite parameter detected"
		DeletePreExistingFiles
	}
	TestPaths
	$servers = ReadServers
	CheckForHotFix -servers $servers
}
Catch
{
	Write-Debug "Unhandled Exception in Main. Exiting now"
	exit
}
Finally
{
  	#Resetting debug preference setting to value used before script was executed
	#this step is not necessary since no actions follow and changing the variable withing a script 
	#does not change the global variable outside of the script's scope.
	$DebugPreference = $OrginalDebugPreference 
	Write-Host "Check Hotfix Script Finished"
}
#***************END MAIN*****************************

