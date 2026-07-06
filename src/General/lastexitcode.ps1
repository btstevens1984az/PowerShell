# Purpose: lastexitcode — General-purpose PowerShell utilities.
$pinglist = "213.29.250.22", "bogus", "127.0.0.1"

Foreach ($machine in $pinglist)
{
ping $machine -n 1
Write-host "$machine lastexitcode is: $lastexitcode" -foregroundcolor yellow
}
$?

Exit 24
