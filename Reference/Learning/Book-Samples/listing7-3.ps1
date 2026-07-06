# Purpose: listing7-3 — Certification notes and learning materials.
function Get-SystemInfo {
    [CmdletBinding()]
    param(
        [string[]]$ComputerName,

        [string]$ErrorLog
    )
    BEGIN {}
    PROCESS {
        Write-Output $ComputerName
        Write-Output $ErrorLog
    }
    END {}
}
