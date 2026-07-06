######################################################
#Date:             1/24/2018
#Revised:          1/24/2018
#Version:          1.0.1
######################################################

<#
.Synopsis
This function will list the HPCA Metadata from a remote computer.
.Description
This function will sort in gridview the Metadata from a remote computer for a 32 or 64 bit host.
.Parameter ComputerName
This parameter is set as the computer's hostname.
This parameter is Mandatory
.Example
Getting Remote Computer's Metadata .EDM files to Out-Gridview
Get-HPCAMetadata -ComputerName 114.148.18.125
#>

Function Get-HPCAMetadata
{
    param
    (
        [Parameter(Mandatory = $true, 
        ValueFromPipeline = $true)]
        [String[]]$ComputerName
     )

#PowerShell script to list the EDM files under the HPCA PATCH\ZSERVICE folder
 Foreach ($cn in $ComputerName) 
    {
    if(Test-Path "\\$cn\c$\Program Files (x86)\Hewlett-Packard\HPCA\Agent\Lib\SYSTEM\RADIA\PATCH\ZSERVICE")
    {
        $Dir = get-childitem "\\$cn\c$\Program Files (x86)\Hewlett-Packard\HPCA\Agent\Lib\SYSTEM\RADIA\PATCH\ZSERVICE" -Recurse -Force
        $Dir | Out-GridView
    }
    else
    {
        $Dir = get-childitem "\\$cn\c$\Program Files\Hewlett-Packard\HPCA\Agent\Lib\SYSTEM\RADIA\PATCH\ZSERVICE" -Recurse -Force
        $Dir | Out-GridView
    }
    }
}