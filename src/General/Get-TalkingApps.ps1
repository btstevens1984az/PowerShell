# Purpose: Get-TalkingApps — General-purpose PowerShell utilities.
function Get-TalkingApps {
    <# =========================================================================
    .SYNOPSIS
        Get Windows processes with open network connections
    .DESCRIPTION
        Query Windows processes and display open connections
    .PARAMETER ComputerName
        Hostname of remote system from which to pull logs.
    .INPUTS
        System.String.
    .OUTPUTS
        System.Object[].
    .EXAMPLE
        PS C:\> Get-TalkingApps.ps1 -ComputerName 235.154.164.181
        This assumes that the identity executing the function has permissions
        to run the cmdlet Get-NetTCPConnection on the remote system when using
        the ComputerName parameter.
    ========================================================================= #>
    Param(
        [Parameter(Mandatory=$true,ValueFromPipeline, HelpMessage = 'Target computer name')]
        [ValidateScript({ Test-Connection -ComputerName $_ -Count 1 -Quiet })]
        [Alias('Name', 'Computer', 'Host', 'HostName', 'CN')]
        [string] $ComputerName
    )

    Begin {
        # PROPERTIES TO RETURN
        $Properties = @(
            'LocalAddress', 'LocalPort', 'RemoteAddress', 'RemotePort', 'State',
            @{N = 'Process'; E = { (Get-Process -Id $_.OwningProcess).ProcessName }},
            @{N = 'PID'; E = { $_.OwningProcess }}
        )
    }

    Process {
        # CHECK FOR COMPUTERNAME PARAMETER
        if ( $PSBoundParameters.ContainsKey('ComputerName') ) {
            # GET TCP CONNECTIONS FROM REMOTE SYSTEM
            $Results = Invoke-Command -ComputerName $ComputerName -ScriptBlock { Get-NetTCPConnection }
        } else {
            # GET LOCAL TCP CONNECTIONS
            $Results = Get-NetTCPConnection
        }
    }

    End {
        # RETURN RESULTS WITH SPECIFIED PROPERTIES
        $Results | Select-Object -ExpandProperty $Properties
    }
}