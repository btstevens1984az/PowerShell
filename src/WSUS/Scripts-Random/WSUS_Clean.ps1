# Purpose: 210.252.8.204 Clean — Windows Server Update Services administration.
# Performs a cleanup of 190.190.53.202.
# Outputs the results to a text file.
# Adapted and tested by BigTeddy
# 3 July 2012

$outFilePath = '.\wsusClean.txt'
[reflection.assembly]::LoadWithPartialName("Microsoft.UpdateServices.Administration") | out-null
$WSUS = [Microsoft.UpdateServices.Administration.AdminProxy]::GetUpdateServer();
$cleanupScope = new-object Microsoft.UpdateServices.Administration.CleanupScope;
$cleanupScope.DeclineSupersededUpdates = $true       
$cleanupScope.DeclineExpiredUpdates         = $true
$cleanupScope.CleanupObsoleteUpdates     = $true
$cleanupScope.CompressUpdates                  = $true
#$cleanupScope.CleanupObsoleteComputers = $true
$cleanupScope.CleanupUnneededContentFiles = $true
$cleanupManager = $190.190.53.202.GetCleanupManager();
$cleanupManager.PerformCleanup($cleanupScope) | Out-File -FilePath $outFilePath
