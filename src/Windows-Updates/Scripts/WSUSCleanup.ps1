# Purpose: WSUSCleanup — Windows Update and patch management.
#This includes some examples of using the WSUS cmdlets
#Specifically if all commands are run this will deny all superceeded updates that were previously applied.
#It is not recommended to do this unless it has been verified that there are not any clients that need those updates.
$WSUS = Get-WsusServer -Name 31.39.1.252 -PortNumber 8530

$updates = Get-WsusUpdate -Approval Approved -UpdateServer $WSUS

Invoke-WsusServerCleanup -CleanupObsoleteComputers -CleanupObsoleteUpdates -CleanupUnneededContentFiles -DeclineExpiredUpdates -DeclineSupersededUpdates

$supinfo = $updatesSuper | group UpdatesSupersedingThisUpdate -notlike "none"

$updatesSuper = $updates | where UpdatesSupersedingThisUpdate -notlike "none"
$updatesSuper | Deny-WsusUpdate -Verbose

Invoke-WsusServerCleanup -CleanupObsoleteComputers -CleanupObsoleteUpdates -CleanupUnneededContentFiles -DeclineExpiredUpdates -DeclineSupersededUpdates -UpdateServer $WSUS


#$updates[5000].update.GetInstallableItems().files
