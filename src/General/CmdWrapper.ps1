# Purpose: CmdWrapper — General-purpose PowerShell utilities.
function Get-CmdWrapper
{
    param(
        [parameter(Mandatory)]
        [validateset("ACEEventLog","Application","COE","Forefront Identity Manager","HardwareEvents","HP Software Framework","Internet Explorer","Key Management Service","MSIT AutoVPN Setup","MSITvSmartcard","OAlerts","PreEmptive","Security","System","Windows Azure","Windows PowerShell")]
        [string]$LogName,
        [int]$Newest
    )

    Get-eventlog @psboundparameters
}
Show-Command Get-CmdWrapper
#Get-EventLog -LogName Application -Newest 10