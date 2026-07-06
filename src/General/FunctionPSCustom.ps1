# Purpose: FunctionPSCustom — General-purpose PowerShell utilities.
#In SimpleDemos
Function Get-CompInfo
{
    param([string[]]$computername = 'localhost')

    foreach ($computer in $computername)
    {
        $OSINFO = Get-CimInstance -ClassName Win32_operatingsystem -computername $computer
        $Computerinfo = Get-CimInstance -ClassName Win32_Computersystem -computername $computer
        $Cdrive =  Get-CimInstance -Query "SELECT * FROM Win32_LogicalDisk WHERE DeviceID='C:'" -ComputerName $computer
        [pscustomobject]@{
                            ComputerName = $computer
                            OSName = $OSINFO.Caption
                            OSInstallDate = $OSINFO.InstallDate
                            LastBootUpTime = $OSINFO.LastBootUpTime
                            Domain = $Computerinfo.Domain
                            BootupState = $Computerinfo.BootStatus
                            OSDriveSpaceGB = [int]($Cdrive.FreeSpace / 1GB)
                            }
    }
}
<#
$computerinfo = get-compinfo -computername 78.127.144.219,dc2,vmhost5,testsrv5
$computerinfo | Out-GridView
$computerinfo | export-csv -NoTypeInformation -Path .\computerinfo.csv
psedit .\computerinfo.csv
$computerinfo | Export-Clixml .\computerinfo.xml
$computerinfo | Where-Object OSDriveSpaceGB -lt 100
$computerinfo | Select-Object -Property Computername,OSName,Domain

$computerinfo | ConvertTo-Html -CssUri .\example.css | out-file computerinfo.htm
ii .\computerinfo.htm
#>