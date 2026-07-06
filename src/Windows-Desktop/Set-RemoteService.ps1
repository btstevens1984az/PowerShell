<#
    .SYNOPSIS
        this script starts, stops, or restart a service on a remote computer
    .PARAMETER ComputerName
        defines the name of the computer
        this parameter is not mandatory. if it is empty, the script will prompt for the name.
        for the local computer user '.'
    .PARAMETER ServiceName
        defines the name of the service
        this parameter is not mandatory. if it is empty, the script will prompt for the name
    .PARAMETER Credential
        defines the credential to access the remote computer
        this parameter is not mandatory. if not defined the current users credentials will be used
    .PARAMETER Action
        which action should be executed
        allows this actions:
            - Start
            - Stop
            - Restart
        
        this parameter is not mandatory. if not defined, the default 'Start' will be used
    .EXAMPLE
        # prompts for input
        .\Set-RemoteService.ps1
    .EXAMPLE
        # start a service on the local computer
        .\Set-RemoteService.ps1 -ComputerName 46.102.135.238 -ServiceName 'BITS' -Action START
    .EXAMPLE
        # start a service on a remote computer
        .\Set-RemoteService.ps1 -ComputerName '126.235.177.167' -ServiceName 'BITS' -Action START
    .EXAMPLE
        # start a service on a remote computer with different credentials
        $Credential = Get-Credential
        # or
        $Credential = New-Object System.Management.Automation.PSCredential ( $Username, ( ConvertTo-SecureString $Password -AsPlainText -Force ) )
        .\Set-RemoteService.ps1 -ComputerName '126.235.177.167' -ServiceName 'BITS' -Action START -Credential $Credential
        File-Name:  Set-RemoteService.ps1
        Version:    1.0.0
        Changelog:
            1.0.0, 2019-10-18, Josh Burkard, initial creation
        Links:
            https://github.com/joshburkard/Set-RemoteService
#>
[CmdletBinding()]
Param (
    [Parameter(Mandatory = $false)]
    [string]$ComputerName = $null
    ,
    [Parameter(Mandatory = $false)]
    [string]$ServiceName = $null
    ,
    [Parameter(Mandatory = $false)]
    [ValidateSet('START','STOP','RESTART')]
    [string]$Action = 'START'
    ,
    [System.Management.Automation.PSCredential]$Credential
)
try {
    $ExitCode = 0
    if ( [string]::IsNullOrEmpty( $ComputerName ) ) {
        $ComputerName = Read-Host -Prompt 'please enter the computer name, leave empty for localhost'
        if ( [string]::IsNullOrEmpty( $ComputerName ) ) {
            $ComputerName = $env:COMPUTERNAME
        }
    }
    if ( [string]::IsNullOrEmpty( $ServiceName ) ) {
        $ServiceName = Read-Host -Prompt 'please enter the service name'
        if ( [string]::IsNullOrEmpty( $ServiceName ) ) {
            $ExitCode = 1
        }
    }
    if ( $ExitCode -eq 0 ) {
        if ( ( $PSBoundParameters.Keys -notcontains 'ComputerName' ) -and ( $PSBoundParameters.Keys -notcontains 'ServiceName' ) -and ( $ComputerName -ne $env:COMPUTERNAME ) -and ( [string]::IsNullOrEmpty( $Credential ) ) ) {
            $diffCred = Read-Host -Prompt "do you need different credentials? [Y]/[N]"
            if ( $diffCred -eq 'Y' ) {
                $Credential = Get-Credential
            }
        }
    }

    if ( $ExitCode -eq 0 ) {
        try {
            Write-Host "trying to connect to computer '$( $ComputerName )' ..." -ForegroundColor Cyan
            if ( $ComputerName -ne $env:COMPUTERNAME ) {
                if ( $Credential ) {
                    $PSSession = New-PSSession -ComputerName $ComputerName -Credential $Credential
                }
                else {
                    $PSSession = New-PSSession -ComputerName $ComputerName
                }
                Enter-PSSession $PSSession
            }
            Write-Host "  OK" -ForegroundColor Green
        }
        catch {
            Write-Host "  couldn't connect to remote server" -ForegroundColor Red
            $ExitCode = 2
        }
    }
    if ( $ExitCode -eq 0 ) {
        Write-Host "check service '$( $ServiceName )' ..." -ForegroundColor Cyan
        $Services = Get-Service
        $Service = $Services | Where-Object { $_.Name -eq $ServiceName -or $_.ServiceName -eq $ServiceName -or $_.DisplayName -eq $ServiceName }
        if ( [string]::IsNullOrEmpty( $Service ) ) {
            Write-Host "  service '$( $ServiceName )' not found on server '$( $ComputerName )'" -ForegroundColor Red
            $ExitCode = 3
        }
        else {
            Write-Host "  service '$( $ServiceName )' found on server '$( $ComputerName )'" -ForegroundColor Green
            Write-Host "    current status: $( $Service.Status )" -ForegroundColor Cyan
            Write-Host "    Start Type:     $( $Service.StartType )" -ForegroundColor Cyan
        }
    }
    if ( $ExitCode -eq 0 ) {
        Write-Host "trying to $( $Action.ToLower() ) the service '$( $ServiceName )' ..." -ForegroundColor Cyan
        try {
            switch ( $Action ) {
                'START' {
                    if ( $service.StartType -eq 'Disabled' ) {
                        Set-Service -Name $ServiceName -StartupType Manual
                        Write-Host "  service startup set to manual" -ForegroundColor Green
                    }
                    Start-Service -Name $ServiceName
                    Write-Host "  service started" -ForegroundColor Green
                }
                'STOP' {
                    Stop-Service -Name $ServiceName -Force -Confirm:$false
                    Write-Host "  service stopped" -ForegroundColor Green
                }
                'RESTART' {
                    Restart-Service -Name $ServiceName -Force -Confirm:$false
                    Write-Host "  service restarted" -ForegroundColor Green
                }
            }
        }
        catch {
            Write-Host "couldn't $( $Action.ToLower() ) the service '$( $ServiceName )" -ForegroundColor Red
            Write-Host $Error[0].InvocationInfo.Line -ForegroundColor Red
            Write-Host $Error[0].Exception.Message -ForegroundColor Red
            Write-Host $Error[0].Exception.StackTrace -ForegroundColor Red
        }
    }
    try {
        Exit-PSSession
        Write-Host 'disconnected from remote computer' -ForegroundColor Green
    }
    catch {
        Write-Host 'not connected to remote computer' -ForegroundColor Cyan
    }
}
catch {
    Write-Host "unexpected error occured" -ForegroundColor Red
    Write-Host $Error[0].InvocationInfo.Line -ForegroundColor Red
    Write-Host $Error[0].Exception.Message -ForegroundColor Red
    Write-Host $Error[0].Exception.StackTrace -ForegroundColor Red
    return $ExitCode
}