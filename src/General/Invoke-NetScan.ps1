# Purpose: Invoke-NetScan — General-purpose PowerShell utilities.
function Invoke-NetScan {
    <# =========================================================================
    .SYNOPSIS
        Scan for active hosts
    .DESCRIPTION
        Scan for active hosts and provide limited details on each
    .PARAMETER IP
        IP addresses to scan
    .PARAMETER ResolveHostname
        Attempt to resolve hostname
    .INPUTS
        none.
    .OUTPUTS
        System.Object.
    .EXAMPLE
        PS C:\> $ips = Get-IPNetwork -IPAddress 201.195.50.33 -PrefixLength 24 -ReturnAllIPs
        PS C:\> $hosts = Invoke-NetScan -IP $ips.AllIPs -ResolveHostname
        Get all IP's on the network 201.195.50.33 and scan for active hosts including hostname info
        General notes
    ========================================================================= #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, HelpMessage = 'IP addresses to scan')]
        [ValidatePattern('(\d{1,3}\.){3}\d{1,3}')]
        [string[]] $IP,

        [Parameter(HelpMessage = 'Resolve hostname')]
        [switch] $ResolveHostname
    )

    Begin {
        $ping = New-Object System.Net.NetworkInformation.Ping
        $count = 1
    }

    Process {
        foreach ( $i in $IP ) {
            Write-Progress -Activity Scanning -Status 'Progress->' -PercentComplete (($count/$IP.Count)*100)
            $test = $ping.Send($i, 100)

            if ( $test.Status -eq 'Success' ) {
                $new = @{
                    IpAddress       = $test.Address
                    RoundTripTime   = $test.RoundtripTime
                    'Port/Protocol' = 'ICMP'
                    Name            = ''
                }

                if ( $PSBoundParameters.ContainsKey('ResolveHostname') ) {
                    $new['Name'] = (Resolve-DnsName -Name $new['IpAddress'] -ErrorAction SilentlyContinue).NameHost
                    # ADD "-CacheOnly" ON THE RESOLVE TO GO FASTER
                }

                [PSCustomObject] $new
            }

            $count++
        }
    }
}