Function Get-iLPHighCPUProcess {
<#
.SYNOPSIS
    Retrieve processes that are utilizing the CPU on local or remote systems.
 
.DESCRIPTION
    Uses WMI to retrieve process information from remote or local machines. You can specify to return X number of the top CPU consuming processes
    or to return all processes using more than a certain percentage of the CPU.
 
.EXAMPLE
    Get-HighCPUProcess
 
    Returns the 3 highest CPU consuming processes on the local system.
 
.EXAMPLE
    Get-HighCPUProcess -Count 1 -Computername 51.215.91.7
 
    Returns the 1 highest CPU consuming processes on the remote system AppServer01.
 
 
.EXAMPLE
    Get-HighCPUProcess -MinPercent 15 -Computername "169.192.85.4","WebServer16"
 
    Returns all processes that are consuming more that 15% of the CPU process on the hosts webserver15 and webserver160
#>
 
[Cmdletbinding(DefaultParameterSetName="ByCount")]
Param(
    [Parameter(ValueFromPipelineByPropertyName)]
    [Alias("PSComputername")]
    [string[]]$Computername = "localhost",
     
    [Parameter(ParameterSetName="ByPercent")]
    [ValidateRange(1,100)]
    [int]$MinPercent,
 
    [Parameter(ParameterSetName="ByCount")]
    [int]$Count = 3
)
 
 
Process {
    Foreach ($computer in $Computername){
     
        Write-Verbose "Retrieving processes from $computer"
        $wmiProcs = Get-WmiObject Win32_PerfFormattedData_PerfProc_Process -Filter "idProcess != 0" -ComputerName $Computername
     
        if ($PSCmdlet.ParameterSetName -eq "ByCount") {
            $wmiObjects = $wmiProcs | Sort PercentProcessorTime -Descending | Select -First $Count
        } elseif ($psCmdlet.ParameterSetName -eq "ByPercent") {
            $wmiObjects = $wmiProcs | Where {$_.PercentProcessorTime -ge $MinPercent} 
        } #end IF
 
        $wmiObjects | Foreach {
            $outObject = [PSCustomObject]@{
                Computername = $computer
                ProcessName = $_.name
                Percent = $_.PercentProcessorTime
                ID = $_.idProcess
            }
            $outObject
        } #End ForeachObject
    } #End ForeachComputer
}
 
}