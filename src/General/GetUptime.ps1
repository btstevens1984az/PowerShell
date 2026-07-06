# Purpose: GetUptime — General-purpose PowerShell utilities.
function Get-UpTime
{
    $os = Get-WmiObject win32_operatingsystem
    $friendlyTime =  ((Get-Date) - $os.ConvertToDateTime($os.LastBootUpTime))
    "$($friendlyTime.days) Days, $($friendlyTime.hours) Hours, $($friendlyTime.Minutes) Minutes, and $($friendlyTime.Seconds) Seconds"
}

Get-UpTime