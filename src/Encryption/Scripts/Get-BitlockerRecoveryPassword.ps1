# Purpose: Get-BitlockerRecoveryPassword — PowerShell automation.
function Get-BitlockerRecoveryPassword {
param($DriveLetter = "c:")
    $bit = Get-BitLockerVolume $DriveLetter
    $password = $bit.KeyProtector | where keyprotectortype -eq "RecoveryPassword" 
    $password.recoverypassword

}
Get-BitlockerRecoveryPassword
