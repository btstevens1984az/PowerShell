# Purpose: Search-RegKeysHIDClass — Windows registry read and write operations.
Function Search-RegKeysHIDClass
{
param (
        [parameter(
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)]
        [ValidateScript({ if (Test-Path $_ )
                           {$True}
                           else
                           {throw "Bad path $_"}             
                        })]
        [string]$RegKeyPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{745A17A0-74D3-11D0-B6FE-00A0C90F57DAF}",
        [string]$search = "*"
        )

 Process
{
    $array = @()
    $array = Get-ChildItem $RegKeyPath -Recurse -ErrorAction SilentlyContinue | Get-ItemProperty | Where-Object{ (Get-Member -InputObject $_ -MemberType noteproperty | Where-Object{$_.name -like $search} )}|
    ForEach-Object{ 
                    $hash = @{}    
                    $Propnames = ($_ | Get-Member -MemberType noteproperty |Where-Object{$_.name -like $search} )| Select-Object -ExpandProperty name
                    $hash.RegKeyPath = ($_.pspath -split "::")[1]
                    $hash.PSPath = $_.pspath
                    foreach ($prop in $Propnames )
                    {
                        $hash.$prop = $_.$prop
                    }
                    [pscustomobject] $hash
    }

    $array
}

}