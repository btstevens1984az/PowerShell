# Purpose: VMMDSCSyntax — Core infrastructure automation scripts.
# See xSCVMM_Documentation.html for more help
Get-DscResource -Name xSCVMMAdmin -Syntax
Get-DscResource -Name xSCVMMManagementServerSetup -Syntax
Get-DscResource -Name xSCVMMManagementServerupdate -Syntax
Get-DscResource -Name xSCVMM* | select name