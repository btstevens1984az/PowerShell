# Purpose: Get-dotnetversion — Reusable PowerShell function libraries.
Function Get-dotnetversion{

$Dir = 'hklm:\SOFTWARE\Microsoft\NET Framework Setup\NDP\'

if (Test-Path "$Dir\v2.0.50727") {
    $version = Get-ItemProperty "$Dir\v2.0.50727" -name Version |select -exp Version
  
}

if (Test-Path "$Dir\v3.0") {
    $version = Get-ItemProperty "$Dir\v3.0" -name Version |select -exp Version
    
}

if (Test-Path "$Dir\v3.5") {
    $version = Get-ItemProperty "$Dir\v3.5" -name Version |select -exp Version
   
}

$v4Directory = "$Dir\v4\Full"
if (Test-Path $v4Directory) {
    $version = Get-ItemProperty $v4Directory -name Version | select -expand Version
    
}

If($version){
Write-Host "Hello $env:username. $env:computername's latest Dot Net version is $version" -F green -B red
}

}