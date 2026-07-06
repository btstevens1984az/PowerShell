# Purpose: Get-UninstallString — Reusable PowerShell function libraries.
Function Get-UninstallString {
	<#
		.SYNOPSIS
			Grabs Uninstall String from Regisrty key
		.DESCRIPTION
			Scans the 32 & 64 bit registry to display the Uninstall string and the Registry Key that the holds the searched value
		.PARAMETER DisplayName
			Display Name of the Software that shows in APPWIZ.cpl
			Version:		1.0.0
			Creation Date:	1/3/2018
	#>
	Param(

		[Parameter(Mandatory=$true)]
		[string]$DisplayName

	)
	function Test-RegistryValue {

		param (

			[parameter(Mandatory=$true)]
			[ValidateNotNullOrEmpty()]$Path,

			[parameter(Mandatory=$true)]
			[ValidateNotNullOrEmpty()]$Value
		)

		try {

			Get-ItemProperty -Path registry::$Path | Select-Object -ExpandProperty $Value -ErrorAction Stop | Out-Null
			return $true
		}

		catch {

			return $false

		}

	}

	$PATHS = @("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall")

	$RegKeys=@()
	$UninstallKey=@()
	forEach($path in $paths){

		$RegKeys += Get-ChildItem -Path $path | Select-Object -ExpandProperty Name 
	}


	forEach($key in $RegKeys)

	{
		$uniobj = New-Object System.Object

			
		if(Test-RegistryValue -Path $key -Value DisplayName)
		{ 
			$Name = Get-ItemProperty registry::$key | Select-Object -expandProperty DisplayName
				
			
			if($Name -like "*$DisplayName*")
			{
				$uniobj | Add-Member -type NoteProperty -name Name -Value $name
				$uniobj | Add-Member -type NoteProperty -Name Uninstall_String -Value (Get-ItemProperty registry::$key | Select-Object -expandProperty UninstallString)
				$uniobj | Add-Member -type NoteProperty -Name Registry_Key -Value $key      
			
				$UninstallKey += $uniobj

			}
			
		}
			
	}
	
	return $UninstallKey
}