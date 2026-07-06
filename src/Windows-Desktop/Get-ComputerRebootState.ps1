# Purpose: Get-ComputerRebootState — Windows desktop configuration and management.
﻿Function Get-ComputerRebootState {
    [cmdletbinding()]
    Param (
        [parameter(ValueFromPipeLine=$True)]
        [string[]]$Computer
    )
    Process {
        ForEach ($c in $computer) {
            If (Test-Connection -Computer $c -Count 1 -Quiet) {
                Try {
                    Write-Verbose "Connecting to $c"
                    $updatesession =  [activator]::CreateInstance([type]::GetTypeFromProgID("Microsoft.Update.Session",$c))
                    Write-Verbose "Creating Update Searcher"
                    $updatesearcher = $updatesession.CreateUpdateSearcher()
                    Write-Verbose "Performing query for recently installed updates that require reboot"
                    $searchresult = $updatesearcher.Search("RebootRequired=1")
                    Write-Verbose "Found $(@($searchresult.updates).count) updates"
                    Switch (@($searchresult.updates).count) {
                        {$_ -eq 0} {
                            New-Object PSObject -Property @{Computer = $c;RebootRequired = $False}
                        }
                        {$_ -ge 1} {
                            New-Object PSObject -Property @{Computer = $c;RebootRequired = $True}            
                        }
                    }
                } Catch {
                   New-Object PSObject -Property @{Computer = $c;RebootRequired = 'NA'}        
                }
            } Else {
               New-Object PSObject -Property @{Computer = $c;RebootRequired = 'Offline'}            
            }
        }
    }
}