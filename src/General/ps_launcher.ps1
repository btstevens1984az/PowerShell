# Purpose: ps launcher — General-purpose PowerShell utilities.
#Starting of the script set these 2 vars on the to be accessed by everything.
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition #get directory of the script.
$scriptName = ($MyInvocation.MyCommand).Name
$log = ("{0}\{1}.log" -f $scriptPath,$scriptName.Replace(".ps1","")) 


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
				[int]$NoRedirect=1
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
				if ($NoRedirect -eq "0") { $output 	}
				else { 	$output | Out-File -Append -FilePath $LogPath }
			}
		End { $datetime=0;$Message=0;}
			
	}


#will get the scripts 
$ps_scripts = Get-ChildItem -Path $scriptPath -Include *.ps1 -Exclude $scriptName -Recurse | sort -Property $_.Name
    Write-log "****************************************************************" -logpath $log
    Write-log "    Starting of Procedure" -logpath $log
    Write-log "****************************************************************" -logpath $log
	Write-log "Launching All scripts under this directory : $scriptPath" -LogPath $log
	Write-log ("Number of scripts 	: {0}" -f ($ps_scripts | Measure-object).Count) -LogPath $log

 foreach ($ps_script in $ps_scripts)
 {
 	$start_time = ""

	#launching scripts 
	Write-log  "============================================" -LogPath $log
	
	Write-log ("ScriptName      : {0}" -f $ps_script.Name) -LogPath $log
	Write-log ("Directory       : {0}" -f $ps_script.Directory) -LogPath $log
	Write-log ("Created         : {0}" -f $ps_script.CreationTime) -LogPath $log
	Write-log ("Lastupdated     : {0}" -f $ps_script.LastWriteTime) -LogPath $log
    $start_time = "StartTime       : $(Get-Date -format F)" 
	Invoke-Expression "$ps_script" #quotes in case there is spaces.
    if($LASTEXITCODE -ne 0)
        {
            Write-log ("Return Code     : {0}" -f $LASTEXITCODE) -LogPath $log -status Error
        }
    else
        {
            Write-log ("Return Code     : {0}" -f $LASTEXITCODE) -LogPath $log
        }
	
	Write-log   $start_time -LogPath $log
	Write-log  "EndTime         : $(Get-Date -format F)" -LogPath $log
	Write-log  "============================================" -logPath $log
 }
