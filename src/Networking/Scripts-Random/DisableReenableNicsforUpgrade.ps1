# Purpose: DisableReenableNicsforUpgrade — Network diagnostics, DNS, DHCP, and connectivity.
$vmm = Get-SCVMMServer -ComputerName 193.192.149.147
$vms2 = Get-SCVirtualMachine -VMHost vmhost5
$vms2 = $vms2 | where name -ne "scvmm2012"
$nics2 = $vms2 | Get-SCVirtualNetworkAdapter
$KaylosVMNet = Get-SCVMNetwork  -Name kaylos 
#$nics2 | Set-SCVirtualNetworkAdapter -NoConnection -NoLogicalNetwork -Verbose
$nics2 | Set-SCVirtualNetworkAdapter -VMNetwork $KaylosVMNet -VirtualNetwork "Kaylos_Switch" -Verbose