# Purpose: createDiffs — General-purpose PowerShell utilities.
﻿#things to add
#doesn't connect to network
#doesn't automatically turn on VM
#Computer name information is not passed to the template.
Import-module NewDiffDiskVMModule -ErrorAction Stop
$computernames = "contoso2dc1","contoso2dc2","contoso2ICA1","contoso2ROOTCA","contoso2web1"
$temp = "Fabrikamdc1","FabrikamPSA","contoso2client"
$parentVHD = "d:\VMs\parents\Win2k8r2.vhd"
$ChildVHDPath = "d:\VMs\children\"
$hostComputer = "VMhost4.kaylos.lab"
$TemplateName = "2008r2templatewsp1"
$VMM = "Vmm.kaylos.lab"


$computernames | %{ New-DiffVM -ParentVHDPath $parentVHD -NewChildVHDPath "$ChildVHDPath$($_).vhd" -HostComputerName $hostComputer -VirtualMachineName $_ -TemplateName $TemplateName -VirtualMachineServerName $VMM }
