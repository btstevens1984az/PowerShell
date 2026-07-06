# Purpose: SimpleTry — General-purpose PowerShell utilities.
try
{
    "trying"
    Get-Process -ErrorAction stop -ErrorVariable myerr -Name notepads
    Get-Service netlogon


}
catch [Microsoft.PowerShell.Commands.ProcessCommandException]
{
    $_.exception.ProcessName + "Does not exist"
    $procName = Read-Host "Enter the correct Process Name"
    Get-Process -Name $procname
    #$_ | Format-List * -Force
}
catch
{

    $_ | Format-List * -Force
}
Finally
{

 "clean up"
}

"next command"