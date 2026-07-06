# Purpose: TestCIM — Cross-cutting logging, error handling, and utilities.
#Write-Host "testing"
function Test-WMI
{
    param ($computer = ".",$class="Win32_operatingsystem",$session)
try
{
    If($session)
    {Get-CimInstance -ClassName $class -CimSession $session -ErrorVariable WMIError -ErrorAction SilentlyContinue}
    else
    {
        Get-CimInstance -ComputerName $computer -ClassName $class -ErrorVariable WMIError -ErrorAction SilentlyContinue
        if ($wmierror -and -not $session)
        {
            throw $wmierror
        }
    }
}
catch [Microsoft.Management.Infrastructure.CimException]
{
    If ($_.exception.message -like "*A DMTF resource URI was used to access a non-DMTF*")
    {
        
        $CimSessiosOption = New-CimSessionOption -Protocol DCOM
        $CIMSession = New-CimSession -ComputerName $computer -SessionOption $CimSessiosOption
        testwmi -session $CimSessios -class $class
    }
    else
    {throw $_}

}
Finally
{

}


}
$computerName = "testsrv5"
Test-WMI -computer $computerName