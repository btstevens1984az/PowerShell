# Purpose: Search-RegKeysDisplayClass — Windows registry read and write operations.
Function Search-RegKeysDisplayClass
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
        [string]$RegKeyPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4D36E968-E325-11CE-BFC1-08002BE10318}",
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