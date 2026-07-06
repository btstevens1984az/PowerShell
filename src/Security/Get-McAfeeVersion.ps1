# Purpose: Get-McAfeeVersion — Security auditing and compliance checks.
function Get-McAfeeVersion
{
	param ($Computer)
	#Found Function https://gallery.technet.microsoft.com/scriptcenter/f5f96771-215e-4114-be0b-09c80f5f2c6f

	$ProductVer = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $Computer).OpenSubKey('SOFTWARE\McAfee\DesktopProtection').GetValue('szProductVer')
	$EngineVer = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $Computer).OpenSubKey('SOFTWARE\McAfee\AVEngine').GetValue('EngineVersionMajor')
	$DatVer = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $Computer).OpenSubKey('SOFTWARE\McAfee\AVEngine').GetValue('AVDatVersion')
    New-Object psobject -Property @{
        ComputerName = $Computer
	    ProductVersion =$ProductVer
	    EngineVersion =$EngineVer
	    DatVersion =$DatVer
    }

}