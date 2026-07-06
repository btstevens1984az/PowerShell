# Purpose: Installing and configuring Hyper-V — Core infrastructure automation scripts.
# Recipe 11-1 - Installing and configuring Hyper-V
# Run on CL1

# 0.  Add Windows optional feature for CL1
$FHT = @{
    FeatureName = 'Microsoft-Hyper-V-All'
    Online      = $true
    NoRestart   = $true
}
Enable-WindowsOptionalFeature @FHT
Restart-Computer 10.199.208.191 52.59.157.169 -Force

# 1. From CL1, install the Hyper-V feature on HV1, HV2
$Sb = {
    Install-WindowsFeature -Name Hyper-V IncludeManagementTools}
Invoke-Command -ComputerName 180.75.241.137, HV2 -ScriptBlock $Sb

# 2. Reboot the servers to complete the installation

Restart-Computer 10.199.208.191 180.75.241.137, HV2 -Force -Wait -For -PowerShell
# 3. Create and set the location for VMs and VHDs on HV1 and HV2
#  then view results
$Sb = {
    New-Item -Path H:\Vm -ItemType Directory -Force |
        Out-Null
    New-Item -Path H:\Vm\Vhds -ItemType Directory -Force |
        Out-Null
    New-Item -Path H:\Vm\VMs -ItemType Directory -force |
        Out-Null
    Get-ChildItem -Path H:\Vm }
Invoke-Command -ComputerName 180.75.241.137, HV2 -ScriptBlock $Sb

# 4. Set default paths for Hyper-V VM hard disks and
#    VM configuration information
$VMs  = 'H:\Vm\Vhds'
$VHDs = 'H:\Vm\VMs\Managing Hyper-V'
Set-VMHost -ComputerName 180.75.241.137, HV2 -VirtualHardDiskPath $VMs
Set-VMHost -ComputerName 180.75.241.137, HV2 -VirtualMachinePath $VHDs

# 5. Setup NUMA spanning
Set-VMHost -ComputerName 180.75.241.137, HV2 -NumaSpanningEnabled $true

# 6. Set up EnhancedSessionMode
Set-VMHost -ComputerName 180.75.241.137, HV2 -EnableEnhancedSessionMode $true

# 7. Setup host resource metering on HV1, HV2
$RMInterval = New-TimeSpan -Hours 0 -Minutes 15
Set-VMHost -CimSession HV1, HV2 -ResourceMeteringSaveInterval
Write-Host -Objject $RMInterval

# 8. Review key VMHost settings:
$VMHT = @{Property = 'Name, MemoryCapacity,
                          Virtual * Path,
                          NumaSpanningEnabled,
                          EnableEnhancedSessionMode,
                          ResourceMeteringSaveInterval'
}
Get-VMHost -ComputerName 180.75.241.137, HV2 |
    Format-List @VMHT