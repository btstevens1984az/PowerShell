# Purpose: get-biosinfo — Hardware and software inventory collection.
$bioschar = DATA {ConvertFrom-StringData -StringData @'
7 = PCI is supported
8 = PC Card (PCMCIA) is supported
9 = Plug and Play is supported
11 = BIOS is Upgradable (Flash)
15 = Boot from CD is supported
33 = USB Legacy is supported
'@}
function get-biosinfo {
[CmdletBinding()]
param (
 [parameter(ValueFromPipeline=$true,
 ValueFromPipelineByPropertyName=$true)]
 [string]$computername="$env:COMPUTERNAME"
)
PROCESS {
 Get-WmiObject -Class Win32_Bios `
-ComputerName $computername |
 Select BuildNumber, CurrentLanguage, InstallableLanguages,
 Manufacturer, Name, PrimaryBIOS,
 @{Name="Release Date";
 Expression={ $_.ConvertToDateTime( $_.ReleaseDate) }},
 SerialNumber, SMBIOSBIOSVersion, SMBIOSMajorVersion,
 SMBIOSMinorVersion, SMBIOSPresent, Status, Version
 "BIOS Characteristics:"
 Get-WmiObject -Class Win32_Bios -ComputerName $computername |
 Select -ExpandProperty BiosCharacteristics |
 foreach {$bioschar["$($_)"]}
}}