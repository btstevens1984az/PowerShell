# Purpose: Invoke-ServerCheckList — General-purpose PowerShell utilities.
<#    .Synopsis     Executes a series of WMI commands against a computer   .Description    Executes a series of WMI commands against a computer    CHECKLISTTYPE: Server   .Link     Http://toolmaker.brycoretechnologies.com #>

[CmdletBinding()]
 Param (
    $ComputerName = $env:COMPUTERNAME
    
 )

if (Test-Connection -Computer $ComputerName -Count 1 -BufferSize 16 -Quiet ) { 

$FS_CheckListResults = [ordered]@{}

#$FS_CheckListResults.Header = "Server Checklist for {0} ran on {1}" -f $ComputerName, (Get-Date)

# Parameters to pass to the checklist queries.
# We only pass the computer name and the login credentials if required
$checklistparams = @{}

$checklistparams.ComputerName = $ComputerName

if ($FS_Credential) {

    $checklistparams.Credential = $FS_Credential
}

$FS_CheckListResults.System = Get-WmiObject -class Win32_OperatingSystem  @checklistparams | Select-Object @{Name='Computername';Expression={$_.CSName}},
                          @{Name='OS';Expression={$_.Caption}}, @{Name='ServicePack';Expression={$_.CSDVersion}}, free*memory, totalv* ,NumberOfProcesses, @{Name='LastBoot';
                          Expression={$_.ConvertToDateTime($_.LastBootupTime) | Out-String}}, @{Name='Uptime';Expression={(Get-Date) - ($_.ConvertToDateTime($_.LastBootupTime)) }}

$FS_CheckListResults.Processor = Get-WmiObject -class Win32_ComputerSystem @checklistparams | Select-Object -Property Manufacturer,Model, 
                            @{Name='Architecture';Expression={$_.SystemType}}, @{Name='Processors';Expression={$_.NumberOfProcessors}}

$FS_CheckListResults.HardDisk = Get-WmiObject -class Win32_LogicalDisk -Filter 'Drivetype=3' @checklistparams | Select-Object DeviceID, 
                                @{Name='SizeGB';Expression={[Math]::Round($_.Size/1GB,0)}}, @{Name='FreeGB';Expression={[Math]::Round($_.FreeSpace/1GB,0)}},
                                @{Name='PercentFree';Expression={[Math]::Round((($_.FreeSpace/1GB) / ($_.Size/1GB) * 100),0)}}

$FS_CheckListResults.Service = Get-WmiObject -class Win32_Service @checklistparams -Filter "(StartMode = 'Auto' and State != 'Running')"  `
                                               | Select-Object Name,Displayname,StartMode

# Get logs for last 24 hours
$last = [System.Management.ManagementDateTimeConverter]::ToDmtfDateTime((Get-Date).AddHours(-24))

$FS_CheckListResults.SystemLog = Get-WmiObject -class Win32_NTLogEvent @checklistparams -Filter "(LogFile = 'System' and TimeGenerated 
                                 >='$last') and (EventType = 1 or EventType = 2)" | Select-Object @{Name='TimeGenerated';Expression={$_.ConvertToDateTime($_.TimeGenerated)}} `
                                 ,EventCode, SourceName, Type, Message

$FS_CheckListResults.ApplicationLog = Get-WmiObject -class Win32_NTLogEvent @checklistparams -Filter "(LogFile = 'Application' and 
                                      TimeGenerated >='$last') and (EventType = 1 or EventType = 2)" | Select-Object @{Name='TimeGenerated'
                                      ;Expression={$_.ConvertToDateTime($_.TimeGenerated)}} ,EventCode, SourceName, Type, Message


 #$FS_CheckListResults

 $header = "Server Checklist for {0} ran on {1}" -f ($ComputerName, (Get-Date))

 $fsresult = Format-FSTypes -InputObject $FS_CheckListResults -Type 'ForeScript.Types.ServerChecklist' -Header $header
 $fsresult

}
else {
  
  "Could not connect to computer $ComputerName ...`r`n" 


}