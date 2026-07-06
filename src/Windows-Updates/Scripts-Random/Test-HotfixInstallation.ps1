# Purpose: Test-HotfixInstallation — Windows Update and patch management.
##############################################################################
##
## Test-HotfixInstallation.ps1
##
## From Windows PowerShell
##
## Determine if a hotfix is installed on a computer
##
##  PS >Test-HotfixInstallation KB925228 114.148.18.125
##  True
##
##############################################################################
Function Test-HotFixInstallation {
param(
  $hotfix = $(throw "Please specify a hotfix ID"),
  $computer = "."
  )


## Create the WMI query to determine if the hotfix is installed
$filter = "HotFixID='$hotfix'"
$results = Get-WmiObject Win32_QuickfixEngineering `
    -Filter $filter -Computer $computer

## Return the results as a boolean, which tells us if the hotfix is installed
[bool] $results
}