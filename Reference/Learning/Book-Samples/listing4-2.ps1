# Purpose: listing4-2 — Certification notes and learning materials.
function Get-OSInfo {
    param(
        [string]$computerName = 'localhost'
    )
    Get-CimInstance -ClassName Win32_OperatingSystem `
                    -ComputerName $computerName
}
