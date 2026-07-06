# Purpose: Connect-RemotePS — Reusable PowerShell function libraries.
function Connect-RemotePS {
    <#
    .SYNOPSIS
    Enter a powershell session on a remote machine
    
    .DESCRIPTION
    Enter a powershell session on a remote machine
    
    .PARAMETER Computer
    Name of remote computer

    .PARAMETER NewWindow
    Opens the remote powershell session in a new window
        
    .EXAMPLE
    Connect-RemotePS -Computer 168.23.139.1
    Opens a powershell session to PC01 in the current console window

    .EXAMPLE
    Connect-RemotePS -Computer 168.23.139.1 -NewWindow
    Opens a powershell session to PC01 in a new console window

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
        [switch]$NewWindow
    )

    begin {
        if (!(Test-Connection $Computer -Count 2 -Quiet)) {
            throw "Machine may be offline"                        
        }
        if (!([bool](Test-WSMan -ComputerName $Computer -ErrorAction SilentlyContinue))) {
            throw "PowerShell remoting is not enabled on the Remote Machine"                       
        }

    }
    process {
        if ($NewWindow.IsPresent) {
            Start-Process powershell.exe -ArgumentList "-noexit &Enter-Pssession -computer $Computer"           
        } else {
            enter-pssession -computer $Computer
        }
    }
}