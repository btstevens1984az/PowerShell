# Purpose: SelectObjectDiskInfo — Storage management and disk operations.
function Get-DiskspaceInfo
{
    param([string[]]$computername = "localhost")
    $FreeGB = @{
                    name="FreeGB"
                    expression = { [int]($_.freespace / 1GB)}
                }
    $SizeGB = @{
                    n="SizeGB"
                    e = { [int]($_.size / 1GB)}
                }
    $ComputerNameProp = @{
                            label = "Computername"
                            expression = {$_.__server}
                         }                 
    $diskobjs = Get-WmiObject -Class Win32_logicalDisk -ComputerName $computername -Filter "drivetype=3"
    $diskobjs | Select-Object $ComputerNameProp,DeviceID,$FreeGB,$SizeGB
}

Get-DiskspaceInfo -computername 78.127.144.219,localhost,dc2 | where freegb -lt 50
#Get-DiskspaceInfo -computername 78.127.144.219,localhost,dc2 | ConvertTo-Html -CssUri .\example.css |
#Out-File diskreport.htm