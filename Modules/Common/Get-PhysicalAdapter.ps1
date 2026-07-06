Function Get-PhysicalAdapter {
<#
.Synopsis
Get-PhysicalAdapter retrieves the physical network adapter information from one or more computers.
.DESCRIPTION
Get-PhysicalAdapter uses WMI to retrieve the Win32_networkadapter instances from one or more computers. It displays each adapter's MAC address, adapter type,
Device ID, name and speed.
.PARAMETER ComputerName
The computer name or names to query. This is mandatory.
.EXAMPLE
Get-PhysicalAdapter -ComputerName localhost
.EXAMPLE
Get-PhysicalAdapter -ComputerName 72.37.86.123
#>
function Get-PhysicalAdapter {
  [CmdletBinding()]
  Param
  (
    [Parameter(Mandatory = $false,
      ValueFromPipelineByPropertyName = $false,
      Position = 0)]
    [Alias('hostname')]
    [string[]]$ComputerName
  )

  Begin {
    Write-Verbose "Connecting to $ComputerName"
  }
  Process {
    Get-WmiObject  win32_networkadapter -ComputerName $ComputerName |
      Where-Object -FilterScript {$_.PhysicalAdapter} |
      Select-Object MACAddress, AdapterType, DeviceID, Name, Speed
  }
  End {
    Write-Verbose "Finished running command"
  }
}
}