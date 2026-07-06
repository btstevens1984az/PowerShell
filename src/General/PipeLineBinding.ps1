# Purpose: PipeLineBinding — General-purpose PowerShell utilities.
function Get-DiskSpace
{
    Param(
        [parameter(Mandatory=$true,
                   ValueFromPipeline=$true, 
                   HelpMessage="Computer to read disk information from",
                   ValueFromPipelineByPropertyName=$true)]
        [string[]]$ComputerName,

        [parameter(ValueFromPipelineByPropertyName=$true)]
        [string[]]$DriveLetter="C"
    )
    process
    {
        $propFreePrecent = @{label="FreespacePercent";expression={"{0:P2}" -f ($_.freespace / $_.Size)}}
        $propFreespaceGB = @{l="FreespaceGB";e={"{0:N2}" -f ($_.freespace / 1GB)}}
        $propComputerName = @{name = "ComputerName";expression = {$_.__Server}}
        $FreeSpaceReadable= @{name="FreeSpaceReadable" ;expression={
                                                        if ($_.freespace -gt 1TB)
                                                        { 
                                                            "$([int](($_.freespace)/1TB)) TB"
                                                        }
                                                        elseif ($_.freespace -gt 1GB)
                                                        { 
                                                            "$([int](($_.freespace)/1GB)) GB"
                                                        }
                                                        elseif ($_.freespace -gt 1MB)
                                                        { "$([int](($_.freespace)/1MB)) MB"}
                                                        elseif ($_.freespace -gt 1KB)
                                                        { "$([int](($_.freespace)/1KB)) KB"}
                                                        else
                                                        {0}
                                                        }
                                                    }
        $DiskInfo = Get-WmiObject Win32_LogicalDisk -ComputerName $ComputerName
        $DiskInfo | Where-Object { $DriveLetter -contains $_.DeviceID.Substring(0, 1)} |
        Select-Object $propComputerName,DeviceID,$FreeSpaceReadable,$propFreePrecent,$propFreespaceGB
    }
}

"localhost" | Get-DiskSpace
$computerNames = "Vmhost4","vmhost5"
$PipeData = $computernames | %{new-object psobject -Property @{"ComputerName"=$_; "DriveLetter"=@("C","F")}}
$PipeData | Get-DiskSpace | FT -AutoSize
#mandatory Help
Get-DiskSpace