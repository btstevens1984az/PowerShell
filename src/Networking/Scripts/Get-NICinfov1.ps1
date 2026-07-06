<#
.Synopsis
   Get-NicInfo will return basic NIC information including NIC link speed.
.DESCRIPTION
   Get-NicInfo will return basic NIC information including NIC link speed.
.EXAMPLE
   Get-NicInfo
.EXAMPLE
   Get-NicInfo -computer "computer1"
.EXAMPLE
   Get-NicInfo -computer "computer1","computer2"
.EXAMPLE
   Get-Content .\computernames.txt | Get-NicInfo

#>
function Get-NicInfo
{
    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(ValueFromPipeline=$true,
                   Position=0)]
        [string[]]$computerName="."
    )

    Begin
    {
        $LinkSpeed = @{name="LinkSpeed"
          expression={(Get-WmiObject -class Win32_networkadapter  -ComputerName $computerName -filter "index=$($_.index)").speed} 
          }
          $computerNameProp = @{name="ComputerName";expression = {$_.__server}}
    }
    Process
    {
        Get-WmiObject Win32_networkadapterconfiguration -Filter "IPenabled =true" -ComputerName $computerName | 
        Select-Object $computerNameProp,Description,$LinkSpeed,MACAddress,IPAddress,DNSServerSearchOrder,index
    }
}
