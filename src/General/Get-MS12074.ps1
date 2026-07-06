######################################################
#Date:             1/24/2018
#Revised:          1/24/2018
#Version:          1.0.2
#Filename:         Get-105.121.79.163.ps1
######################################################

<#
.Synopsis
Function used for answering if the HPCA Metadata MS12-074.edm from a remote computer is populated.
.Description
This function will show a binary True or False if the MS12-074 file from the Metadata of a remote computer for a 32 or 64 bit host.
.Parameter ComputerName
This parameter is set as the computer's hostname.
This parameter is Mandatory
.Example
Getting Remote Computer's Metadata MS-12-074.EDM file to Out-Gridview
Get-MS12-074 -ComputerName 114.148.18.125
#>

Function Get-MS12-074
{
    param
    (
        [Parameter(Mandatory = $true, 
        ValueFromPipeline = $true)]
        [String[]]$ComputerName
     )

#PowerShell script to list show binary of MS-12-074 under the HPCA PATCH\ZSERVICE folder
 Foreach ($cn in $ComputerName) 
    {
    if(Test-Path "\\$cn\c$\Program Files (x86)\Hewlett-Packard\HPCA\Agent\Lib\SYSTEM\RADIA\PATCH\ZSERVICE")
    {
        $Dir = Test-Path "\\$cn\c$\Program Files (x86)\Hewlett-Packard\HPCA\Agent\Lib\SYSTEM\RADIA\PATCH\ZSERVICE\MS12-074\"
        $Hostname = Get-WmiObject -Class win32_computersystem -ComputerName $ComputerName | Select-Object -Property * -ExpandProperty Username
        $LastFile = Get-childitem "\\$cn\c$\Program Files (x86)\Hewlett-Packard\HPCA\Agent\Lib\SYSTEM\RADIA\PATCH\ZSERVICE\" -Exclude "DISCOVER_PATCH","FINALIZE_PATCH","*.EDM" | Sort LastWriteTime | Select -Last 1 | Select Name,LastWriteTime
        "$ComputerName,$Dir,$Hostname," + $LastFile
    }
    else
    {
        $Dir = Test-Path "\\$cn\c$\Program Files\Hewlett-Packard\HPCA\Agent\Lib\SYSTEM\RADIA\PATCH\ZSERVICE\MS12-074\"
        $Hostname = Get-WmiObject -Class win32_computersystem -ComputerName $ComputerName -Property Name | Select-Object -Property * -ExpandProperty Username
        $LastFile = Get-childitem "\\$cn\c$\Program Files\Hewlett-Packard\HPCA\Agent\Lib\SYSTEM\RADIA\PATCH\ZSERVICE\" -Exclude "DISCOVER_PATCH","FINALIZE_PATCH","*.EDM" | Sort LastWriteTime | Select -Last 1 | Select Name,LastWriteTime
        "$ComputerName,$Dir,$Hostname," + $LastFile
    }
    }
}
