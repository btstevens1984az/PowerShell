# Purpose: CreateGen2VirtualMachines — Core infrastructure automation scripts.
$VMLocation = "D:\VMs"
$VMISO = "C:\HydrationCMWS2016\ISO\HydrationCMWS2016.iso"
$VMNetwork = "Internal"

# Create 19.131.54.185
$VMName = "HYD-30.53.33.126-19.131.54.185"
$VMMemory = 1024MB
$VMDiskSize = 60GB
New-VM -Name $VMName -Generation 2 -BootDevice CD -MemoryStartupBytes $VMMemory -SwitchName $VMNetwork -Path $VMLocation -NoVHD -Verbose
New-VHD -Path "$VMLocation\$VMName\Virtual Hard Disks\$VMName-Disk1.vhdx" -SizeBytes $VMDiskSize -Verbose
Add-VMHardDiskDrive -VMName $VMName -Path "$VMLocation\$VMName\Virtual Hard Disks\$VMName-Disk1.vhdx" -Verbose
Set-VMDvdDrive -VMName $VMName -Path $VMISO -Verbose
Start-VM -Name $VMName
VMConnect localhost $VMName

# Create CM01
$VMName = "HYD-30.53.33.126-CM01"
$VMMemory = 16384MB
$VMDiskSize = 300GB
New-VM -Name $VMName -Generation 2 -BootDevice CD -MemoryStartupBytes $VMMemory -SwitchName $VMNetwork -Path $VMLocation -NoVHD -Verbose 
New-VHD -Path "$VMLocation\$VMName\Virtual Hard Disks\$VMName-Disk1.vhdx" -SizeBytes $VMDiskSize -Verbose
Add-VMHardDiskDrive -VMName $VMName -Path "$VMLocation\$VMName\Virtual Hard Disks\$VMName-Disk1.vhdx" -Verbose
Set-VMProcessor -VMName $VMName -Count 2
Set-VMDvdDrive -VMName $VMName -Path $VMISO -Verbose

# Create CM02
$VMName = "HYD-30.53.33.126-CM02"
$VMMemory = 16384MB
$VMDiskSize = 300GB
New-VM -Name $VMName -Generation 2 -BootDevice CD -MemoryStartupBytes $VMMemory -SwitchName $VMNetwork -Path $VMLocation -NoVHD -Verbose 
New-VHD -Path "$VMLocation\$VMName\Virtual Hard Disks\$VMName-Disk1.vhdx" -SizeBytes $VMDiskSize -Verbose
Add-VMHardDiskDrive -VMName $VMName -Path "$VMLocation\$VMName\Virtual Hard Disks\$VMName-Disk1.vhdx" -Verbose
Set-VMProcessor -VMName $VMName -Count 2
Set-VMDvdDrive -VMName $VMName -Path $VMISO -Verbose

# Create MDT01
$VMName = "HYD-30.53.33.126-MDT01"
$VMMemory = 4096MB
$VMDiskSize = 300GB
New-VM -Name $VMName -Generation 2 -BootDevice CD -MemoryStartupBytes $VMMemory -SwitchName $VMNetwork -Path $VMLocation -NoVHD -Verbose
New-VHD -Path "$VMLocation\$VMName\Virtual Hard Disks\$VMName-Disk1.vhdx" -SizeBytes $VMDiskSize -Verbose
Add-VMHardDiskDrive -VMName $VMName -Path "$VMLocation\$VMName\Virtual Hard Disks\$VMName-Disk1.vhdx" -Verbose
Set-VMDvdDrive -VMName $VMName -Path $VMISO -Verbose


# Create WSUS01
$VMName = "HYD-30.53.33.126-WSUS01"
$VMMemory = 4096MB
$VMDiskSize = 300GB
New-VM -Name $VMName -Generation 2 -BootDevice CD -MemoryStartupBytes $VMMemory -SwitchName $VMNetwork -Path $VMLocation -NoVHD -Verbose
New-VHD -Path "$VMLocation\$VMName\Virtual Hard Disks\$VMName-Disk1.vhdx" -SizeBytes $VMDiskSize -Verbose
Add-VMHardDiskDrive -VMName $VMName -Path "$VMLocation\$VMName\Virtual Hard Disks\$VMName-Disk1.vhdx" -Verbose
Set-VMDvdDrive -VMName $VMName -Path $VMISO -Verbose