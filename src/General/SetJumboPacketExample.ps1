# Purpose: SetJumboPacketExample — General-purpose PowerShell utilities.
function Search-RegKeys
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
        [string]$RegKeyPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}",
        [string]$search = "*JumboPacket"
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
search-RegKeys 

$results = Search-RegKeys    

$results | where *jumboPacket -lt 9000 | ForEach-Object { Set-ItemProperty -Path $_.psPath -Name *JumboPacket -Value 9014 }
#Get-NetAdapter | Restart-NetAdapter #optionally restart all Nics