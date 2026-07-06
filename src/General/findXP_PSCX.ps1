# Purpose: findXP PSCX — General-purpose PowerShell utilities.
if (-not (Get-PSSnapin PSCX -ErrorAction SilentlyContinue)) 
{
	Add-PSSnapin PSCX -ErrorAction stop
}

cd nwtraders:\
dir -Recurse | Where-Object{$_.type -match "computer"} `
| %{$_.entry |?{$_.operatingSystem -match "XP"}|FL name,operatingSystem,operatingSystemServicePack }