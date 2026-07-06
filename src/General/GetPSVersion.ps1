# Purpose: GetPSVersion — General-purpose PowerShell utilities.
Function Get-PSVersion
{
    param([string[]]$computername = 'localhost')
    
    Invoke-Command -ScriptBlock {
                    [pscustomobject]@{
                        ComputerName = $env:COMPUTERNAME
                        PSVersion =$PSVersionTable.PSVersion.ToString()
                        PSBuild = $PSVersionTable.PSVersion
                        NetVersion = $PSVersionTable.CLRVersion
                    } 

                } -ComputerName $computername

}

Get-PSVersion -computername 78.127.144.219,testsrv1,dc2 | ogv