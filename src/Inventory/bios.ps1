# Purpose: bios — Hardware and software inventory collection.
param( [string]$strComputer = "." )

$colItems = get-wmiobject -class "Win32_BIOS" -namespace "root\CIMV2" -computername $strComputer

foreach ($objItem in $colItems) {
	write-host "Name                           :" $objItem.Name
	write-host "Version                        :" $objItem.Version
	write-host "Manufacturer                   :" $objItem.Manufacturer
	write-host "SMBIOSBIOS Version             :" $objItem.SMBIOSBIOSVersion
	write-host
}
