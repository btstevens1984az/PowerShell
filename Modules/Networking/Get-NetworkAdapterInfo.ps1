Function Get-NetworkAdapterInfo {
<#
.SYNOPSIS
Get-NetworkAdapterInfo retrieves information about network adapters configuration from one or more computers.
.DESCRIPTION
Get-NetworkAdapterInfo uses WMI to retrieve the Win32_NetworkAdapterConfiguration instances from one or more computers.
.PARAMETER computerName
The computer(s) to query.
.PARAMETER dhcpEnabled
Display only adapters with DHCP enabled.
.PARAMETER ipEnabled
Display only adapters with the IP Protocol enabled.
.EXAMPLE
Get-NetworkAdapterInfo -computerName 152.89.151.171 -dhcpEnabled -ipEnabled
Display information about the network adapters of the it5 computer, which have DHCP and the IP Protocol enabled. 
#>

[CmdletBinding()]
param (
    [string] $computerName = 'localhost',
    [switch] $dhcpEnabled,
    [switch] $ipEnabled
)

Write-Verbose "Start quering network adapters"

if ($PSBoundParameters.keys -contains "dhcpEnabled" -and $PSBoundParameters.keys -contains "ipEnabled") {
    $filter = "dhcpEnabled=$true and ipEnabled=$true"    
} elseif ($PSBoundParameters.keys -contains "ipEnabled") {
    $filter = "ipEnabled=$true"    
} elseif ($PSBoundParameters.keys -contains "dhcpEnabled") {
    $filter = "dhcpEnabled=$true"    
}  else {
    $filter = ""
}

Get-WmiObject -ComputerName $computerName -Class Win32_NetworkAdapterConfiguration -Filter $filter | Format-Table -AutoSize -Wrap

Write-Verbose "Finished quering network adapters"
}