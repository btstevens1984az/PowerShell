# Purpose: JumboFrameStuff — General-purpose PowerShell utilities.
 Get-NetAdapter | ? status -eq 'up' | 
 Set-NetAdapterAdvancedProperty -RegistryKeyword "*JumboPacket" -RegistryValue 9014

 Get-NetAdapter | ? status -eq 'up' | 
 Get-NetAdapterAdvancedProperty -RegistryKeyword "*JumboPacket"

 Get-NetAdapter | ? status -eq 'up' | 
 Set-NetAdapterAdvancedProperty -RegistryKeyword "*JumboPacket" -RegistryValue 9014

 #Ethernet                  Jumbo Packet                   Disabled                       *JumboPacket    {15
 Get-NetAdapter -Name vethernet* | Set-NetAdapterAdvancedProperty -RegistryKeyword "*JumboPacket" -RegistryValue 1500
 #1500 

 #ping -f -l 8900 scvmm2012