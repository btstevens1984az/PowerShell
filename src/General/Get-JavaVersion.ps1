# Purpose: Get-JavaVersion — General-purpose PowerShell utilities.
function Get-Java{
    param
    (
        #[Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [String]$cn
    )
        $Java = Get-ChildItem 'C:\Program Files (x86)\Java\' -force| Where-Object {$_.Name -match "j"} | Write-Host
 }