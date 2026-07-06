# Purpose: Confirm-Session — General-purpose PowerShell utilities.
Function Confirm-Session{

if ($SCRIPT:session_id -eq $null){
    Write-Host "You need to login firts. Try 'Invoke-NexposeLogin'." -ForegroundColor Red
    break;
    }


}