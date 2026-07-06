# Purpose: ImplicitRemoting — General-purpose PowerShell utilities.
$computer = "dc2"
$ModuleName = "ActiveDirectory"
$session = new-pssession -comp $computer
Invoke-Command -Command {import-module $USING:MODULENAME} -Session $session #using scope modifier is new to PSv3 use $args and -arguments in v2
Import-PSSession $session -Module $ModuleName -prefix $computer 


<#
function Import-RemoteModule
{
    param(  $computer = "dc2",
            $ModuleName = "ActiveDirectory")
            $session = new-pssession -comp $computer
            Invoke-Command -Command {import-module $USING:MODULENAME} -Session $session #using scope modifier is new to PSv3
            Import-PSSession $session -Module $ModuleName -prefix $computer 
}
#>