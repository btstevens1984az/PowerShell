# Purpose: TryCatch — General-purpose PowerShell utilities.
$computers = "dc2","bogus","dccore"
$ErrorActionPreference = "stop"

try
{
	
	
	foreach ($computer in $computers)
	{
		try{
		$computer
		Gwmi -ComputerName $computer -Class Win32_OperatingSystem
		}
	
		catch
		{
		 Write-Host "inner caught it"
		 $Error.Clear()
		continue
		 
		}
		Finally
		{
		"inner finally"
		}
	
	}
	
}
catch
{
 Write-Host "caught it"
 $Error.Clear()
 continue
 
}
Finally
{
"finally"
}