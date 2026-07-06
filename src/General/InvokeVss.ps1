# Purpose: InvokeVss — General-purpose PowerShell utilities.
#$computers = "kms","dc2","dc4","vmhost4","vmhost5","gamingsrv01","mymovies","rd"
$computers = Get-DemoComputers | where {$_ -notlike "*xp*"}
$results = Invoke-Command -FilePath "$PSScriptRoot\Vss.ps1" -ComputerName $computers
$orderedresults = $results | Select-Object PScomputername,Writername,State,LastError,WriterID,WriterInstanceID
$orderedresults | Out-GridView