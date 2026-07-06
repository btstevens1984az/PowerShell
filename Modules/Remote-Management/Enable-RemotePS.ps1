# Purpose: Enable-RemotePS — Reusable PowerShell function libraries.
function Enable-RemotePS {
    <#
    .SYNOPSIS
    Enables PSremoting on a remote machine
    
    .DESCRIPTION
    Enables PSRemoting on a remote machine by using PSEXEC to initiate the Enable-PSRemoting command on the remote machine.
    
    .PARAMETER Computer
    Name of remote computer
    
    .PARAMETER SpecifyPSEXEC
    This parameter is needed if you havent specified the PSEXEC file in your PATH variable
    
    .PARAMETER ExeLocation
    Location of the PSEXEC Executable
    
    .EXAMPLE
    Enable-RemotePS -Computer 168.23.139.1
    Enables PSRemoting on PC01 using the PSEXEC exe found in your PATH variable

    .EXAMPLE
    Enable-RemotePS -Computer 168.23.139.1 -SpecifyPSExec -ExeLocation C:\TMP\PsExec.exe
    Enables PSRemoting on PC01 using the PsExec.exe program found in C:\TMP\
    
    #>
    [CmdletBinding(DefaultParameterSetName='Default')]
    param (
        [parameter(Position=0,
        Mandatory=$true,
        ValueFromPipeline=$true,
        ParameterSetName='Default')]
        [parameter(Position=0,
        Mandatory=$true, 
        ValueFromPipeline=$true,
        ParameterSetName='PSEXEC')]
        [string]$Computer,

        [parameter(Position=1,ParameterSetName='PSEXEC')]
        [switch]$SpecifyPSEXEC,

        [parameter(Position=2,Mandatory=$true,ParameterSetName='PSEXEC')]
        [String]$ExeLocation        
        
    )

    begin {
        if ($SpecifyPSEXEC.IsPresent) {            
            if (!(Test-Path $ExeLocation)) {                
                Write-Error "PSEXEC file not found"
                return
            } else {
                $PSEXEC = $ExeLocation
                Write-Verbose "PSEXEC.EXE location set to: $PSEXEC" 
            }
        } else {
            $PSEXEC = (Get-Command PSEXEC.exe).source
            Write-Verbose "PSEXEC.EXE location set to: $PSEXEC" 
        }
    }
    process {
        if (Test-Connection $Computer -Count 2 -Quiet) {
            Write-Verbose "Running Enable-PSRemoting"
            & $PSEXEC \\$computer -nobanner -s -d powershell.exe "Enable-PSRemoting -Force" >$null 2>$null    
        } else {            
            Write-Error "Unable to connect to remote machine"
        }
    }
}