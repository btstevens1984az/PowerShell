Function Get-ComputerInfoV2 {

<#
.SYNOPSIS
    Lists basic Computer/Server information from CIM queries.
.DESCRIPTION
    Lists basic Computer/Server information from CIM queries.

    This script accepts a single computer as input, or multiple computers. If no value is given, 'localhost' us used as the default value.
.PARAMETER  Computer
    Name of computer or server. Preferably, use Fully Qualified Domain Names
.INPUTS
    System.String
.OUTPUTS
    System.Management.Automation.PSCustomObject
.EXAMPLE
    Get-ComputerInfo.ps1
.EXAMPLE
    Get-ComputerInfo.ps1 -Computer 231.186.49.194
.Example
    Get-ComputerInfo.ps1 -Computer 133.242.99.1,compb.company.com
.Example
    Get-ComputerInfo.ps1 -Computer (Get-Content C:\ListOfComputers.txt)
    Email: See About_MCPoshTools for contact information
    Last Updated: 20161205
    Last Updated By: K. Kirkpatrick
    Last Update Notes:
    - Converted WMI calls to CIM; much easier for firewall rules
    - Minor syntax changes
#>

    [OutputType([System.Management.Automation.PSCustomObject])]
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param (
        [Parameter(Position = 0, Mandatory = $false, ParameterSetName = 'Default')]
        [ValidateNotNullOrEmpty()]
        [System.string[]]$ComputerName = "$ENV:COMPUTERNAME"
    )

    BEGIN {

        #Requires -Version 3
        Set-StrictMode -Version Latest

    } # end BEGIN block

    PROCESS {

        foreach ($computer in $ComputerName) {

            $win32CompSys      = $null
            $win32OpSys        = $null
            $win32Bios         = $null
            $win32SysEncl      = $null
            $ComputerShortName = $null
            $ComputerIPv4      = $null
            $UptimeData        = $null
            $win32Proc         = $null
            $visibleRAM        = $null

            if (Test-Connection $computer -Count 2 -Quiet) {

                try {

                    Write-Verbose -Message "[Get-ComputerInfo] Working on {$computer}"

                    # legacy code used for WMI-based queries
                    #$win32CompSys = Get-WmiObject -Query "SELECT Name, Domain, Model FROM win32_computersystem" -ComputerName $computer
                    #$win32OpSys   = Get-WmiObject -Query "SELECT TotalVisibleMemorySize, LastBootupTime, Description, Caption, ServicePackMajorVersion FROM Win32_operatingsystem" -ComputerName $computer
                    #win32Bios    = Get-WmiObject -Query "SELECT Manufacturer, SerialNumber FROM win32_BIOS" -ComputerName $computer -ErrorAction 'SilentlyContinue'
                    #$win32Proc    = Get-WmiObject -Query "SELECT Name FROM win32_Processor" -ComputerName $computer -ErrorAction 'SilentlyContinue' | Select-Object -First 1
                    #$win32SysEncl = Get-WmiObject -Query "SELECT SMBIOSAssetTag FROM win32_SystemEnclosure" -ComputerName $computer -ErrorAction 'SilentlyContinue'

                    $win32CompSys = Get-CimInstance -Query "SELECT Name, Domain, Model FROM win32_computersystem" -ComputerName $computer
                    $win32OpSys   = Get-CimInstance -Query "SELECT TotalVisibleMemorySize, LastBootupTime, Description, Caption, ServicePackMajorVersion FROM Win32_operatingsystem" -ComputerName $computer
                    $win32Bios    = Get-CimInstance -Query "SELECT Manufacturer, SerialNumber FROM win32_BIOS" -ComputerName $computer -ErrorAction 'SilentlyContinue'
                    $win32Proc    = Get-CimInstance -Query "SELECT Name FROM win32_Processor" -ComputerName $computer -ErrorAction 'SilentlyContinue' | Select-Object -First 1
                    $win32SysEncl = Get-CimInstance -Query "SELECT SMBIOSAssetTag FROM win32_SystemEnclosure" -ComputerName $computer -ErrorAction 'SilentlyContinue'

                    $ComputerShortName = $win32CompSys.Name
                    $ComputerIPv4      = Get-CimInstance -Query "SELECT IPEnabled, IPAddress, IPSubnet, DefaultIPGateway, DNSServerSearchOrder FROM Win32_NetworkAdapterConfiguration" -ComputerName $computer | Where-Object { $_.IPEnabled -eq $true }
                    $UptimeData        = (get-date) - (Get-Date $win32OpSys.lastbootuptime)
                    $visibleRAM        = "{0:N2}" -f ($win32OpSys.TotalVisibleMemorySize/1024/1024)

                    [PSCustomObject] @{
                        ComputerName    = $ComputerShortName.ToUpper()
                        Domain          = $win32CompSys.Domain
                        IPAddress       = $ComputerIPv4.IPAddress -join '|'
                        SubnetMask      = $ComputerIPv4.ipsubnet -join '|'
                        DefaultGateway  = $ComputerIPv4.DefaultIPGateway -join '|'
                        DNSServers      = $ComputerIPv4.DNSServerSearchOrder -join '|'
                        UptimeInDays    = $UptimeData.Days
                        Model           = $win32CompSys.Model
                        Processor       = $win32Proc.Name
                        RAMVisibleInGB  = $visibleRAM
                        Description     = $win32OpSys.Description
                        OperatingSystem = $win32OpSys.Caption
                        ServicePack     = $win32OpSys.ServicePackMajorVersion
                        Manufacturer    = $win32Bios.Manufacturer
                        SerialNumber    = $win32Bios.SerialNumber
                        AssetTag        = $win32SysEncl.SMBIOSAssetTag
                        Ping            = 'Up'
                        Error           = $null
                    } # end [PSCustomObject]

                } catch {

                    Write-Warning -Message "[Get-ComputerInfo][ERROR] Could not query computer {$computer}. $_"

                    [PSCustomObject] @{
                        ComputerName    = $computer
                        Domain          = $null
                        IPAddress       = $null
                        SubnetMask      = $null
                        DefaultGateway  = $null
                        DNSServers      = $null
                        UptimeInDays    = $null
                        Model           = $null
                        Processor       = $null
                        RAMVisibleInGB  = $null
                        Description     = $null
                        OperatingSystem = $null
                        ServicePack     = $null
                        Manufacturer    = $null
                        SerialNumber    = $null
                        AssetTag        = $null
                        Ping            = 'Up'
                        Error           = "Error querying computer : $_"
                    } # end [PSCustomObject]

                } # end catch

            } else {

                Write-Warning -Message "[Get-ComputerInfo][ERROR] Computer {$computer} is unreachable"

                [PSCustomObject] @{
                    ComputerName    = $computer
                    Domain          = $null
                    IPAddress       = $null
                    SubnetMask      = $null
                    DefaultGateway  = $null
                    DNSServers      = $null
                    UptimeInDays    = $null
                    Model           = $null
                    Processor       = $null
                    RAMVisibleInGB  = $null
                    Description     = $null
                    OperatingSystem = $null
                    ServicePack     = $null
                    Manufacturer    = $null
                    SerialNumber    = $null
                    AssetTag        = $null
                    Ping            = 'Down'
                    Error           = 'Unreachable by ICMP (ping)'
                } # end [PSCustomObject]

            } # end else

        } # end foreach

    } # end PROCESS

    END {

        Write-Verbose -Message "[Get-ComputerInfo] Processing Complete"

    } # end END

} # end function Get-ComputerInfo