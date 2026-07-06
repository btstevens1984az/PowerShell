# Purpose: WorkFlowVariablesDemo — General-purpose PowerShell utilities.
#http://technet.microsoft.com/en-us/library/jj574187.aspx
workflow VarTest
{
    $CS = $null
    $test = "test"
    
    $test2 = inlinescript {
        $using:test + " somethingelse"
    }
    parallel
    {
         $workflow:CS = Get-CimInstance -ClassName Win32_ComputerSystem
         $workflow:OS = Get-CimInstance -ClassName Win32_OperatingSystem      
         $workflow:ADUsers = Get-ADUser -filter *
    }
    [pscustomobject]@{
        ComputerSystem = $CS
        OperatingSystem = $OS
        ADUsers = $ADUsers
        Test = $test2

    }
}
vartest


workflow p {


$results = parallel {

Get-CimInstance -ClassName Win32_ComputerSystem
Get-CimInstance -ClassName Win32_OperatingSystem
Get-ADUser -filter *

}

$results

}