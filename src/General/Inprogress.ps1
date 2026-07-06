# Purpose: Inprogress — General-purpose PowerShell utilities.
$start = get-date
$jobs = 1..2 | %{$scriptblock =  [scriptblock]::create("Write-host $_ ; Start-Sleep $_");Start-Job -ScriptBlock $scriptblock }
$jobs | Wait-Job | Receive-Job 
$end = get-date
$end - $start