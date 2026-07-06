# Purpose: listing4-3 — Certification notes and learning materials.
function Get-OSInfo {
    param(
        [string]$computerName = 'localhost'
    )
    Get-CimInstance -ClassName Win32_OperatingSystem `
                    -ComputerName $computerName
}
Get-OSInfo –computername SERVER2
