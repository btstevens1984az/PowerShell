# Purpose: GetHotfixWF — Windows Update and patch management.
workflow Get-HotfixWF
{
    param($computers)
    foreach -parallel ($comp in $computers)
    {
        #inlinescript
        #{
        #    Get-HotFix -ComputerName $using:comp
        #}
        #The following is slower
        Get-HotFix -PSComputerName $comp
    }
}

$computers = "dc2","dc4","vmhost5","deploy","pkiroot"
Write-host "workflow"
$upcomputers = $upcomputers | ? {$_ -ne "vmhost5"}
Measure-Command {$results= Get-HotfixWF -computers $upcomputers}
Write-Host "no workflow"
Measure-Command { $results2 = Get-Hotfix -ComputerName $upcomputers}