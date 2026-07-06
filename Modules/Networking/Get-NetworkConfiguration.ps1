function Get-NetworkConfiguration {

<#
.SYNOPSIS
    Returns basic information about current network connection addressing
.DESCRIPTION
    Returns basic information about current network connection addressing

    Currently, it will return object output for each entry passed to -ComputerName, so that it's easy to generate proper reports
    which might be used for auditing configurations.
.PARAMETER ComputerName
    Name of computer/s
.EXAMPLE
    Get-NetworkConfiguration -Verbose
.EXAMPLE
    Get-NetworkConfiguration -ComputerName 192.163.182.22,140.150.122.161.com -Verbose
.INPUTS
    System.String
.OUTPUTS
    System.Management.Automation.PSCustomObject
    Email: See About_MCPoshTools for contact information
    Last Updated: 20170207
    Last Updated By: K. Kirkpatrick
    Last Update Notes:
    - Fixed error when querying for the default gateway (it was set to return the subnet mask due to copy/paste fail)
#>

    [OutputType([System.Management.Automation.PSCustomObject])]
    [CmdletBinding(DefaultParameterSetName = 'default')]
    param (
        [parameter(Mandatory = $false, Position = 0, ParameterSetName = 'default')]
        [System.String[]]$ComputerName = "$ENV:ComputerName"
    )

    BEGIN {


    } # end BEGIN block

    PROCESS {

        foreach ($computer in $ComputerName) {

            Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Processing computer { $computer }"

            # this could be handled by adding a [ValidateScript()] parameter validation attribute but I put it down here so we can capture and save connection errors in the output
            if (Test-Connection -ComputerName $computer -Count 1 -Quiet) {

                try {

                    $win32Nic = Get-CimInstance -Query 'SELECT ipaddress, ipsubnet, DefaultIPGateway, DHCPEnabled, DNSServerSearchOrder, WINSPrimaryServer, WINSSecondaryServer, MACAddress, Description, ipenabled FROM Win32_NetworkAdapterConfiguration' -ComputerName $computer -ErrorAction Stop |
                    Where-Object { $_.ipenabled -eq $true }

                    foreach ($adapter in $win32Nic) {

                        $SrvName    = $null
                        $SrvIP      = $null
                        $SrvSubnet  = $null
                        $SrvDG      = $null
                        $SrvDHCP    = $null
                        $SrvDNS     = $null
                        $SrvSecDNS  = $null
                        $SrvPriWINS = $null
                        $SrvSecWINS = $null
                        $SrvMAC     = $null
                        $SrvAdapter = $null

                        $SrvName = $computer

                        foreach ($config in $adapter) {

                            $objNicAdapter = @()

                            $SrvIP      = $config.ipaddress -join '|'
                            $SrvSubnet  = $config.ipsubnet -join '|'
                            $SrvDG      = $config.DefaultIPGateway -join '|'
                            $SrvDHCP    = if ($config.DHCPEnabled -eq $True) { "Yes" } else { "No" }
                            $SrvDNS     = $config.DNSServerSearchOrder -join '|'
                            $SrvPriWINS = $config.WINSPrimaryServer
                            $SrvSecWINS = $config.WINSSecondaryServer
                            $SrvMAC     = $config.MACAddress
                            $SrvAdapter = $config.Description

                            [PSCustomObject] @{
                                ComputerName   = $SrvName
                                IPAddress      = if ($SrvIP) { $SrvIP } else { $null }
                                SubnetMask     = if ($SrvSubnet) { $SrvSubnet } else { $null }
                                DefaultGateway = if ($SrvDG) { $SrvDG } else { $null }
                                DHCPEnabled    = if ($SrvDHCP) { $SrvDHCP } else { $null }
                                DNSServers     = if ($SrvDNS) { $SrvDNS } else { $null }
                                WINSPrimary    = if ($SrvPriWINS) { $SrvPriWINS } else { $null }
                                WINSSecondary  = if ($SrvSecWINS) { $SrvSecWINS } else { $null }
                                MACAddress     = if ($SrvMAC) { $SrvMAC } else { $null }
                                Description    = if ($SrvAdapter) { $SrvAdapter } else { $null }
                            } # end [PSCustomObject]

                        } # end foreach $config

                    } # end foreach $adapter

                } catch {

                    Write-Warning -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Could not gather information from computer { $computer }"

                    [PSCustomObject] @{
                        ComputerName   = $computer
                        IPAddress      = $null
                        SubnetMask     = $null
                        DefaultGateway = $null
                        DHCPEnabled    = $null
                        DNSServers     = $null
                        WINSPrimary    = $null
                        WINSSecondary  = $null
                        MACAddress     = $null
                        Description    = $null
                        Error          = "Could not gather information. $_"
                    } # end [PSCustomObject]

                } # end try/catch

            } else {

                Write-Warning -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Could not reach comptuer { $computer }"

               [PSCustomObject] @{
                    ComputerName   = $computer
                    IPAddress      = $null
                    SubnetMask     = $null
                    DefaultGateway = $null
                    DHCPEnabled    = $null
                    DNSServers     = $null
                    WINSPrimary    = $null
                    WINSSecondary  = $null
                    MACAddress     = $null
                    Description    = $null
                    Error          = "Computer not reachable via Ping"
                } # end [PSCustomObject]

            } # end if/else Test-Connection

        } # end foeach $computer

    } # end PROCESS block

    END {

        Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Processing Complete"

    } # end END block

} # end function Get-NetworkConfiguration