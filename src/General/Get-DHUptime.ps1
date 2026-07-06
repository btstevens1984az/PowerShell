<#
.SYNOPSIS
Get-Uptime retrieves boot up information from a Aomputer.
.DESCRIPTION
Get-Uptime uses WMI to retrieve the Win32_OperatingSystem
LastBootuptime property. It displays the start up time
as well as the uptime.

Changelog:
 * Added Credential parameter
 * Changed to property hash table splat method
 * Converted to function to be added to a module.

.PARAMETER ComputerName
The Computer name to query. Default: Localhost.
.EXAMPLE
Get-Uptime -ComputerName 39.243.10.254
Gets the uptime from SERVER-R2
.EXAMPLE
Get-Uptime -ComputerName (Get-Content C:\Temp\Computerlist.txt)
Gets the uptime from a list of computers in c:\Temp\Computerlist.txt.
.EXAMPLE
Get-Uptime -ComputerName 83.1.57.254 -Credential domain\serveradmin
Gets the uptime from SERVER04 using alternate credentials.
#>
Function Get-DHUptime {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false,
                        Position=0,
                        ValueFromPipeline=$true,
                        ValueFromPipelineByPropertyName=$true)]
        [Alias("Name")]
        [string[]]$ComputerName=$env:COMPUTERNAME,
        $Credential = [System.Management.Automation.PSCredential]::Empty
        )

    begin{}

    #Need to verify that the hostname is valid in DNS
    process {
        foreach ($Computer in $ComputerName) {
            try {
                $hostdns = [System.Net.DNS]::GetHostEntry($Computer)
                $OS = Get-WmiObject win32_operatingsystem -ComputerName $Computer -ErrorAction Stop -Credential $Credential
                $BootTime = $OS.ConvertToDateTime($OS.LastBootUpTime)
                $Uptime = $OS.ConvertToDateTime($OS.LocalDateTime) - $boottime
                $propHash = [ordered]@{
                    ComputerName = $Computer
                    BootTime     = $BootTime
                    Uptime       = $Uptime
                    }
                $objComputerUptime = New-Object PSOBject -Property $propHash
                $objComputerUptime
                } 
            catch [Exception] {
                Write-Output "$computer $($_.Exception.Message)"
                #return
                }
        }
    }
    end{}
}