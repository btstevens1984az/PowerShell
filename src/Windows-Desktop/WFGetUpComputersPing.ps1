# Purpose: WFGetUpComputersPing — Windows desktop configuration and management.
workflow WFGetUpComputers {

   param([string[]]$computers)

   foreach –parallel -throttlelimit 500 ($computer in $computers){

    If (Test-Connection -ComputerName $computer -Count 1 -Quiet)
    {$computer}

   }

}
$start = Get-Date
$computers = (Get-ADComputer -Filter *).name
$WFTime = Measure-Command {$UpComputers = WFGetUpComputers -computers $computers}
$UpComputers
$stop = Get-Date
$stop - $start
Write-Host "Workflow time"
$WFTime
