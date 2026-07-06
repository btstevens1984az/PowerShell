# Purpose: Search-RegKeysUSBClass — Windows registry read and write operations.
Function Search-RegKeysUSBClass
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
        [string]$RegKeyPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{36FC9E60-C465-11CF-8056-444553540000}",
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