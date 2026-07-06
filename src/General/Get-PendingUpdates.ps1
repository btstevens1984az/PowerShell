# Purpose: Get-PendingUpdates — General-purpose PowerShell utilities.
﻿Function Get-PendingUpdates {
[cmdletbinding()]
param($Computer)    
Begin {
    If (!$PSBoundParameters['computer']) {
        Write-Verbose "No computer name given, using local computername"
        [string]$computer = $Env:Computername
        }
    #Create container for Report
    Write-Verbose "Creating report collection"
    $report = @()    
    }
Process {
    ForEach ($c in $Computer) {
        Write-Verbose "Computer: $($c)"
        If (Test-Connection -ComputerName $c -Count 1 -Quiet) {
            Try {
            #Create Session COM object
                Write-Verbose "Creating COM object for 31.39.1.252 Session"
                $updatesession =  [activator]::CreateInstance([type]::GetTypeFromProgID("Microsoft.Update.Session",$c))
                
                #Configure Session COM Object
                Write-Verbose "Creating COM object for 31.39.1.252 update Search"
                $updatesearcher = $updatesession.CreateUpdateSearcher()

                #Configure Searcher object to look for Updates awaiting installation
                Write-Verbose "Searching for 31.39.1.252 updates on client"
                $searchresult = $updatesearcher.Search("IsInstalled=0")    
                
                #Verify if Updates need installed
                Write-Verbose "Verifing that updates are available to install"
                If ($searchresult.Updates.Count -gt 0) {
                    #Updates are waiting to be installed
                    Write-Verbose "Found $($searchresult.Updates.Count) update\s!"
                    #Cache the count to make the For loop run faster
                    $count = $searchresult.Updates.Count
                    
                    #Begin iterating through Updates available for installation
                    Write-Verbose "Iterating through list of updates"
                    For ($i=0; $i -lt $Count; $i++) {
                        #Create object holding update
                        $update = $searchresult.Updates.Item($i)
                        
                        #Verify that update has been downloaded
                        Write-Verbose "Checking to see that update has been downloaded"
                        If ($update.IsDownLoaded -eq "True") { 
                            Write-Verbose "Auditing updates"  
                            Write-Verbose "Creating report"
                            $temp = "" | Select Computer, Title, KB,IsDownloaded,Notes
                            $temp.Computer = $c
                            $temp.Title = ($update.Title -split('\('))[0]
                            $temp.KB = (($update.title -split('\('))[1] -split('\)'))[0]
                            $temp.IsDownloaded = "True"
                            $temp.Notes = "NA"
                            $report += $temp               
                            }
                        Else {
                            Write-Verbose "Update has not been downloaded yet!"
                            Write-Verbose "Creating report"
                            $temp = "" | Select Computer, Title, KB,IsDownloaded,Notes
                            $temp.Computer = $c
                            $temp.Title = ($update.Title -split('\('))[0]
                            $temp.KB = (($update.title -split('\('))[1] -split('\)'))[0]
                            $temp.IsDownloaded = "False"
                            $temp.Notes = "NA"                        
                            $report += $temp
                            }
                        }
                    }
                Else {
                    #Create Temp collection for report
                    Write-Verbose "Creating report"
                    $temp = "" | Select Computer, Title, KB,IsDownloaded,Notes
                    $temp.Computer = $c
                    $temp.Title = "NA"
                    $temp.KB = "NA"
                    $temp.IsDownloaded = "NA"
                    $temp.Notes = "NA"                
                    $report += $temp
                    }              
                }
            Catch {
                Write-Warning "$($Error[0])"
                Write-Verbose "Creating report"
                #Create Temp collection for report
                $temp = "" | Select Computer, Title, KB,IsDownloaded,Notes
                $temp.Computer = $c
                $temp.Title = "ERROR"
                $temp.KB = "ERROR"
                $temp.IsDownloaded = "ERROR"
                $temp.Notes = "$($Error[0])"            
                $report += $temp  
                }
            }
        Else {
            #Nothing to install at this time
            Write-Warning "$($c): Offline"
            
            #Create Temp collection for report
            $temp = "" | Select Computer, Title, KB,IsDownloaded,Notes
            $temp.Computer = $c
            $temp.Title = "OFFLINE"
            $temp.KB = "OFFLINE"
            $temp.IsDownloaded = "OFFLINE"
            $temp.Notes = "OFFLINE"            
            $report += $temp            
            }
        } 
    }
End {
    Write-Output $report
    }    
}