# Purpose: GetDemoComputers — Windows desktop configuration and management.
workflow WFGetUpComputers 
{
   param([string[]]$computers,[int]$throttleLimit = 50)

    foreach �parallel -throttlelimit $throttleLimit ($computer in $computers)
   {
    If (Test-Connection -ComputerName $computer -Count 1 -Quiet)
    { 
        $computer
    }
   }
}

function Get-DemoComputers 
{
param([int]$throttleLimit = 50)
$computers = (Get-ADComputer -Filter *).name
$results = WFGetUpComputers -computers $computers
$results
}