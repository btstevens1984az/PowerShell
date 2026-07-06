# Purpose: writedebug — Cross-cutting logging, error handling, and utilities.
function Test-Debug
{
[cmdletbinding()]
param()
$var = "my variable" 
Write-verbose "var=$var"
Write-Debug "var=$var"
Write-Warning "var=$var" 
}
Test-Debug -verbose -Debug 
