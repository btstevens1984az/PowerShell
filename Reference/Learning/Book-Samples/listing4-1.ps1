# Purpose: listing4-1 — Certification notes and learning materials.
param(
    [string]$computerName = 'localhost'
)
Get-CimInstance -ClassName Win32_OperatingSystem `
                -ComputerName $computerName
