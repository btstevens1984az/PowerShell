#$computers = Get-Content C:\temp\computers.txt

Function Get-ServerUpTime {
<#
.Synopsis
   Get-ServerUptime
.DESCRIPTION
   Gets the uptime for the specified servers
.EXAMPLE
    Use a text list of servers to get uptime and log failed connections
   $computers = Get-content .\computers.txt
   Get-ServerUpTime -computername $computers -Verbose -LogFailedConnections
.EXAMPLE
    Get uptime of all servers in Active Directory
    $Computers = Get-adcomputer -filter "operatingsystem -like '*server*'" 
    Get-ServerUpTime -computername $computers.name 
.EXAMPLE
    Use a text list of servers to get uptime and log failed connections
    Get-content .\computers.txt | 
    Get-ServerUpTime  -Verbose -LogFailedConnections | Export-csv UpTimeReport.csv
#>
    [cmdletbinding()]
    param(
    [parameter(ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
    [string[]]$computername = "localhost",
    [switch]$LogFailedConnections,
    [string]$LogName = "failedconnection.txt"
    )

    begin
    {
        if (Test-path ".\$LogName")
        {
            Remove-Item ".\$LogName" -Confirm
        }
    }

    process{
        Foreach ($computer in $computername)
        {
            try{
            Write-Verbose "Attempting to get uptime info from: $computer"
            $result = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $computer -ErrorAction stop
            $result | Add-Member -Name LastBootTime -MemberType ScriptProperty -Value {$this.ConvertToDateTime($this.lastbootuptime)}
            $result | Add-Member -Name ComputerName -MemberType AliasProperty -Value __Server
            write-verbose "$($result.ComputerName) - $($result.LastBootTime)"
            #Function Output
            $result | Select-Object ComputerName,LastBootTime
   
            }
            catch
            {
                Write-verbose "Failed to connect to: $computer"
                if ($LogFailedConnections)
                {
                 $computer >> ".\$LogName"

                }

            }
   
        }
    }
 }
 
 #$results = Get-ServerUpTime -computername $computers -Verbose -LogFailedConnections
 #$results