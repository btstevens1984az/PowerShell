# Purpose: WMIParallel — Cross-cutting logging, error handling, and utilities.
workflow WmiParallel
{
    param([string[]]$Computers)
   $s= foreach -parallel -ThrottleLimit 300 ($comp in $Computers) 
    {
        Get-wmiobject -ClassName Win32_operatingsystem -PSComputerName $comp -ErrorAction SilentlyContinue 
        #write-host "test"
    }
    $s

}
#$demos = Get-DemoComputers

Measure-Command {WmiParallel -Computers $demos}
Measure-Command { Get-WmiObject -Class Win32_operatingsystem -ComputerName $demos -ErrorAction SilentlyContinue}