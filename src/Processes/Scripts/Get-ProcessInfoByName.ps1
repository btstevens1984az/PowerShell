# Purpose: Get-ProcessInfoByName — PowerShell automation.
Function Get-ProcessInfoByName
{
#$error.Clear()
$procName=Read-Host -Prompt "Enter Process Name"
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
    $error | fl * -Force > C:\Temp\ifError.log
    $error | Export-Clixml C:\Temp\iferrors.xml
}
}