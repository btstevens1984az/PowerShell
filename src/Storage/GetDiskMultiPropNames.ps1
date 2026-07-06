# Purpose: GetDiskMultiPropNames — Storage management and disk operations.
function Get-DiskspaceInfo
{
    param(
    [Alias('HostName','IPAddress','__Server')]
    [parameter(ValueFromPipelineByPropertyName,
                ValueFromPipeline)]
    [string[]]$computername = "localhost",
    [parameter(ValueFromPipelineByPropertyName)]
    [string[]]$DeviceID = "c:")
    process 
    {
        foreach ($computer in $computername) {

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
        $diskobjs = Get-WmiObject -Class Win32_logicalDisk -ComputerName $computer -Filter "deviceid='$deviceid'"
        $diskobjs | Select-Object $ComputerNameProp,DeviceID,$FreeGB,$SizeGB
    }
    
    }
}

#by property name
import-csv .\diskinput.csv | get-diskspaceinfo
import-csv .\diskinput2.csv | get-diskspaceinfo
#by Value
"kms","testsrv3" | Get-DiskspaceInfo