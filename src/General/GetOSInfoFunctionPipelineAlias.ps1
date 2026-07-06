# Purpose: GetOSInfoFunctionPipelineAlias — General-purpose PowerShell utilities.
function Get-OsInformation
{
    param(
    [parameter(Mandatory,
               HelpMessage = "Please enter a computer name",
               ValueFromPipeline=$true,
               ValueFromPipelineByPropertyName=$true 
                )]
    [Alias("IPAddress","HostName","__Server")]
    [string[]]$computername)
    Begin{ Write-Verbose "begin OS info gathering"}

    Process
    {
        foreach ($computer in $computername)
        {
        Get-CimInstance -ClassName win32_operatingsystem -ComputerName $computer  | 
         Select-Object PsComputerName,Caption,LastBootUpTime
        }
    }
    end{Write-Verbose "end OS info gathering"}
}


get-content .\computers.txt | Get-OsInformation
get-content .\computers.txt |ForEach-Object{
     Get-OsInformation -computername $_ }

import-csv .\computers.csv | Get-OsInformation
