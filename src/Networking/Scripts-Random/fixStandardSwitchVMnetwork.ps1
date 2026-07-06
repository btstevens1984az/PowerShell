# Purpose: fixStandardSwitchVMnetwork — Network diagnostics, DNS, DHCP, and connectivity.
#example of fixing a standard switch that didn't bind to a logical network and in turn a VM network. 
#This will prevent placements of VMs on that host
#ideally use logical switches instead of standard switches but the below technique is a quick fix.

$net = Get-SCVirtualNetwork | where vmhost -like "*node2*" -ErrorAction Stop
if (-not $net.LogicalNetworks)
{
write-output "adding VM network to HostNetworkadapter on node2"
$public = get-sclogicalnetwork -Name public -ErrorAction Stop
Get-SCVMHostNetworkAdapter -VMHost "2012-node2" | Set-SCVMHostNetworkAdapter -AddOrSetLogicalNetwork $public
Get-SCVMHostCluster | Read-SCVMHostCluster

}