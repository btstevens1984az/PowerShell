# Purpose: CompareLists — General-purpose PowerShell utilities.
$master = Import-Csv C:\cust\Inventory-Master-01-16-2014.csv
$ALLServers = $master."am list" | ? {$_}
$ALLServers += $master."SEP list" | ? {$_}
$ALLServers += $master."ad list" | ? {$_}
$ALLServers += $master."ovo list" | ? {$_}
$ALLServers += $master."VCM Licensed" | ? {$_}
$ALLServers = $ALLServers | % {$_.toupper()} | Select-Object -Unique 
$ALLServers = $ALLServers | ?{ $_ -notMatch "\w\w\wpvm\d+\b"}
$ErrorActionPreference = "silentlycontinue"
$objs = $ALLServers | ForEach-Object {
            
                $newobjhash = @{
                                Name = $_
                                AMlist= ($master."am list" -contains $_)
                                ADlist =($master."ad list" -contains $_)
                                OVOList =($master."ovo list" -contains $_)
                                VCMList =($master."VCM Licensed" -contains $_)
                                SEPList =($master."sep list" -contains $_)
                                DNSQuery=&{if ([system.net.dns]::GetHostAddresses($_))
                                            {
                                                $true
                                            }
                                        }                               
                                     }
                    [pscustomobject]$newobjhash
                    #New-Object -TypeName PSObject -Property $newobjhash

                }

$AllGood = $objs | Where-Object {$_.vcmlist -and $_.ovolist -and $_.AMlist -and $_.Adlist -and $_.seplist}

