# Purpose: get-servicedata — Windows desktop configuration and management.
# Get-ServiceData

Function Get-ServiceData {
[cmdletbinding()]
Param(
[parameter(Position=0,Mandatory=$True,HelpMessage="Enter a computername")]
[ValidateNotNullorEmpty()]
[string]$Computername,
[Parameter(Position=1)]
[ValidateSet("Running","Stopped","All","%")]
[string]$Filter="All"
)
Try {
Write-Verbose "Getting $filter services from $computername"
if ($Filter -eq "All") {
$filter='%'
Write-Verbose "Using WMI filter: state Like '$Filter'"
}
$services=Get-WmiObject -Class Win32_Service -ComputerName $Computername -filter "State Like '$Filter'"
#write selected results to the pipeline
$services | Select Name,Displayname,State,StartMode,StartName
}
Catch {
Write-Warning "Failed to get services from $Computername. $_.Exception.Message"
}
} #end function

get-servicedata