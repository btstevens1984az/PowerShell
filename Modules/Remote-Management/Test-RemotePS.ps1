# Purpose: Test-RemotePS — Reusable PowerShell function libraries.
function Test-RemotePS {
    <#
    .SYNOPSIS
    Tests if PSRemoting is enabled and working on a remote machine
    
    .DESCRIPTION
    Tests if PSRemoting is enabled and working on a remote machine.
    
    .PARAMETER Computer
    Name of remote computer

    .PARAMETER Silent
    Returns output as True or False
        
    .EXAMPLE
    Test-RemotePS -Computer 168.23.139.1
    Tests if PSRemoting is enabled on PC01 and returns a message to the console

    .EXAMPLE
    Test-RemotePS -Computer 168.23.139.1 -Silent
    Tests if PSRemoting is enabled on PC01 and returns output as either True or False
    
    #>
    [CmdletBinding(DefaultParameterSetName='Default')]
    param (
        [parameter(Position=0,
        Mandatory=$true,
        ValueFromPipeline=$true,
        ParameterSetName='Default')]
        [string]$Computer,

        [parameter(Position=1,
        ValueFromPipeline=$true,
        ParameterSetName='Default')]
        [switch]$Silent
    )

    begin {
        if (!(Test-Connection $Computer -Count 2 -Quiet)) {
            throw "Machine may be offline"                        
        }
    }
    process {
        $Result = [bool](Test-WSMan -ComputerName $Computer -ErrorAction SilentlyContinue)
    }
    end {
        if ($silent.IsPresent) {
            $Result
        } else {
            if ($Result -eq $true) {
                Write-Host "PSRemoting is enabled" -ForegroundColor Green
            } else {
                Write-Host "PSRemoting is not enabled or is broken" -ForegroundColor Gray
            }
        }
    }
}