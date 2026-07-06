# Purpose: Get-LastLoginsBack30Days — Reusable PowerShell function libraries.
# Get last logged on users
# 28.12.2017
Function Get-LastLoginsBack30Days {
$credential = Get-Credential -Message "Please enter the credential to access the computer."

Write-Host "Get last logged on users"
Write-Host "  Logon Types:"
Write-Host "  1  -> All types"
Write-Host "  2  -> Interactive"
Write-Host "  3  -> Network"
Write-Host "  4  -> Batch"
Write-Host "  5  -> Service"
Write-Host "  7  -> Unlock"
Write-Host "  8  -> NetworkCleartext"
Write-Host "  9  -> NewCredentials"
Write-Host "  10 -> RemoteInteractive"
Write-Host "  11 -> CachedInteractive"

$computer_name = Read-Host "Computer name"
$logon_type = Read-Host "Logon Type"
$number_of_events = Read-Host "Number of event logs which will check to detect last logged on users"

$last_logged_on_users = Invoke-Command -ComputerName $computer_name -Credential $credential -ArgumentList $number_of_events, $logon_type -ScriptBlock {

    $newest = $args[0]
    $logon_type = $args[1]
    If($logon_type -eq 1) {
        $events = Get-EventLog Security -AsBaseObject -InstanceId 4624 -Newest $newest -EntryType SuccessAudit
    } Else {
        $events = Get-EventLog Security -AsBaseObject -InstanceId 4624 -Newest $newest -EntryType SuccessAudit | Where-Object { ($_.Message -match "Logon Type:\s+$logon_type") }
    }

    $users = @()
    ForEach($event in $events) {
    
        If ($event.Message -match "New Logon:\s*Security ID:\s*.*\s*Account Name:\s*(\w+)" -and $users -notcontains $matches[1]) {
            $users += $matches[1]
        }

    }
    
    return $users

}

If($last_logged_on_users.Count -eq 0) {
    Write-Host "No logged on users in $number_of_events event logs"
} Else {
    Write-Host $last_logged_on_users
}
}