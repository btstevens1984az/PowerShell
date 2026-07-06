# Purpose: IfErrors — Cross-cutting logging, error handling, and utilities.
#$error.Clear()
$procName=Read-Host -Prompt "enter process name"
try {Get-Process $procName -ErrorAction stop -ErrorVariable myErr}
catch{"caught it"}
if ($myerr)
{
    $procName=Read-Host -Prompt "Processname incorrect ($procName), enter process name:"
    Get-Process $procName

}
get-service netlogon


if ($error)
{
    $error | fl * -Force > .\ifError.log
    $error | Export-Clixml .\iferrors.xml
}
