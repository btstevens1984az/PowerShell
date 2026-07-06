# Purpose: CreateVMFromDiff — General-purpose PowerShell utilities.
$comp = "2012-node2"
$vmname = "Contoso-svr2"
$path = "C:\labfiles\vms"
new-vm -Name $vmname -MemoryStartupBytes 512MB -SwitchName Public -ComputerName $comp -Path $path
Set-VMMemory -VMName $vmname -DynamicMemoryEnabled $true -MinimumBytes 512MB -ComputerName $comp 
New-VHD -ParentPath 'c:\labfiles\vhds\sysprep vhds\training_WS2012_RTM_sysprep.vhdx' -ComputerName $comp -Path "$path\contososvr2.vhdx"
Add-VMHardDiskDrive -VMName $vmname -ControllerLocation 0 -ControllerNumber 0 -ControllerType IDE -ComputerName $comp 
Set-VMHardDiskDrive -VMName $vmname -ControllerLocation 0 -ControllerNumber 0 -ControllerType IDE -ComputerName $comp -Path "$path\contososvr2.vhdx"
Start-VM -Name $vmname -ComputerName $comp

