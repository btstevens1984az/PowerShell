# Purpose: Start-PoshPAIG — General-purpose PowerShell utilities.
﻿#region Synchronized Collections
$uiHash = [hashtable]::Synchronized(@{})
$runspaceHash = [hashtable]::Synchronized(@{})
$jobs = [system.collections.arraylist]::Synchronized((New-Object System.Collections.ArrayList))
$jobCleanup = [hashtable]::Synchronized(@{})
$Global:updateAudit = [system.collections.arraylist]::Synchronized((New-Object System.Collections.ArrayList))
$Global:installAudit = [system.collections.arraylist]::Synchronized((New-Object System.Collections.ArrayList))
$Global:servicesAudit = [system.collections.arraylist]::Synchronized((New-Object System.Collections.ArrayList))
$Global:installedUpdates = [system.collections.arraylist]::Synchronized((New-Object System.Collections.ArrayList))
#endregion

#region Startup Checks and configurations
#Determine if running from ISE
Write-Verbose "Checking to see if running from console"
If ($Host.name -eq "Windows PowerShell ISE Host") {
    Write-Warning "Unable to run this from the PowerShell ISE due to issues with PSexec!`nPlease run from console."
    Break
}

#Validate user is an Administrator
Write-Verbose "Checking Administrator credentials"
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "You are not running this as an Administrator!`nRe-running script and will prompt for administrator credentials."
    Start-Process -Verb "Runas" -File PowerShell.exe -Argument "-STA -noprofile -file $($myinvocation.mycommand.definition)"
    Break
}

#Ensure that we are running the GUI from the correct location
Set-Location $(Split-Path $MyInvocation.MyCommand.Path)
$Global:Path = $(Split-Path $MyInvocation.MyCommand.Path)
Write-Debug "Current location: $Path"

#Check for PSExec
Write-Verbose "Checking for psexec.exe"
If (-Not (Test-Path psexec.exe)) {
    Write-Warning ("Psexec.exe missing from {0}!`n Please place file in the path so UI can work properly" -f (Split-Path $MyInvocation.MyCommand.Path))
    Break
}

#Determine if this instance of PowerShell can run WPF 
Write-Verbose "Checking the apartment state"
If ($host.Runspace.ApartmentState -ne "STA") {
    Write-Warning "This script must be run in PowerShell started using -STA switch!`nScript will attempt to open PowerShell in STA and run re-run script."
    Start-Process -File PowerShell.exe -Argument "-STA -noprofile -WindowStyle hidden -file $($myinvocation.mycommand.definition)"
    Break
}

#Load Required Assemblies
Add-Type –assemblyName PresentationFramework
Add-Type –assemblyName PresentationCore
Add-Type –assemblyName WindowsBase
Add-Type –assemblyName Microsoft.VisualBasic
Add-Type –assemblyName System.Windows.Forms

#DotSource Help script
. ".\HelpFiles\HelpOverview.ps1"

#DotSource About script
. ".\HelpFiles\About.ps1"
#endregion

Function Set-PoshPAIGOption {
    If (Test-Path (Join-Path $Path 'options.xml')) {
        $Optionshash = Import-Clixml -Path (Join-Path $Path 'options.xml')
        $Global:maxConcurrentJobs = $Optionshash['MaxJobs']
        $Global:MaxRebootJobs = $Optionshash['MaxRebootJobs']
        If ($Optionshash['ReportPath']) {
            $Global:reportpath = $Optionshash['ReportPath']
    
        } Else {
            $Optionshash['ReportPath'] = $Global:reportpath = (Join-Path $Home 'Desktop')
        }
    } Else {
        #Default Options
        $optionshash = @{
            MaxJobs = 5
            MaxRebootJobs = 5
            ReportPath = (Join-Path $env:USERPROFILE 'Desktop')
        }
        $Global:maxConcurrentJobs = 5
        $Global:MaxRebootJobs = 5
        $Global:reportpath = (Join-Path $env:USERPROFILE 'Desktop')
    }
    $optionshash | Export-Clixml -Path (Join-Path $pwd 'options.xml') -Force
}

#Function for Debug output
Function Global:Show-DebugState {
    Write-Debug ("Number of Items: {0}" -f $uiHash.Listview.ItemsSource.count)
    Write-Debug ("First Item: {0}" -f $uiHash.Listview.ItemsSource[0].Computer)
    Write-Debug ("Last Item: {0}" -f $uiHash.Listview.ItemsSource[$($uiHash.Listview.ItemsSource.count) -1].Computer)
    Write-Debug ("Max Progress Bar: {0}" -f $uiHash.ProgressBar.Maximum)
}

#Reboot Warning Message
Function Show-RebootWarning {
    $title = "Reboot Server Warning"
    $message = "You are about to reboot servers which can affect the environment! `nAre you sure you want to do this?"
    $button = [System.Windows.Forms.MessageBoxButtons]::YesNo
    $icon = [Windows.Forms.MessageBoxIcon]::Warning
    [windows.forms.messagebox]::Show($message,$title,$button,$icon)
}

#Format and display errors
Function Get-Error {
    Process {
        ForEach ($err in $error) {
            Switch ($err) {
                {$err -is [System.Management.Automation.ErrorRecord]} {
                        $hash = @{
                        Category = $err.categoryinfo.Category
                        Activity = $err.categoryinfo.Activity
                        Reason = $err.categoryinfo.Reason
                        Type = $err.GetType().ToString()
                        Exception = ($err.exception -split ": ")[1]
                        QualifiedError = $err.FullyQualifiedErrorId
                        CharacterNumber = $err.InvocationInfo.OffsetInLine
                        LineNumber = $err.InvocationInfo.ScriptLineNumber
                        Line = $err.InvocationInfo.Line
                        TargetObject = $err.TargetObject
                        }
                    }               
                Default {
                    $hash = @{
                        Category = $err.errorrecord.categoryinfo.category
                        Activity = $err.errorrecord.categoryinfo.Activity
                        Reason = $err.errorrecord.categoryinfo.Reason
                        Type = $err.GetType().ToString()
                        Exception = ($err.errorrecord.exception -split ": ")[1]
                        QualifiedError = $err.errorrecord.FullyQualifiedErrorId
                        CharacterNumber = $err.errorrecord.InvocationInfo.OffsetInLine
                        LineNumber = $err.errorrecord.InvocationInfo.ScriptLineNumber
                        Line = $err.errorrecord.InvocationInfo.Line                    
                        TargetObject = $err.errorrecord.TargetObject
                    }               
                }                        
            }
        $object = New-Object PSObject -Property $hash
        $object.PSTypeNames.Insert(0,'ErrorInformation')
        $object
        }
    }
}

#Add new server to GUI
Function Add-Server {
    $computer = [Microsoft.VisualBasic.Interaction]::InputBox("Enter a server name or names. Separate servers with a comma (,) or semi-colon (;).", "Add Server/s")
    If (-Not [System.String]::IsNullOrEmpty($computer)) {
        [string[]]$computername = $computer -split ",|;"
        ForEach ($computer in $computername) { 
            If (-NOT [System.String]::IsNullOrEmpty($computer)) {
                $clientObservable.Add((
                    New-Object PSObject -Property @{
                        Computer = ($computer).Trim()
                        Audited = 0 -as [int]
                        Installed = 0 -as [int]
                        InstallErrors = 0 -as [int]
                        Services = 0 -as [int]
                        Notes = $Null
                    }
                ))     
                Show-DebugState
            }
        }
    } 
}

#Remove server from GUI
Function Remove-Server {
    $Servers = @($uiHash.Listview.SelectedItems)
    ForEach ($server in $servers) {
        $clientObservable.Remove($server)
    }
    $uiHash.ProgressBar.Maximum = $uiHash.Listview.ItemsSource.count
    Show-DebugState  
}

#Report Generation function
Function Start-Report {
    Write-Debug ("Data: {0}" -f $uiHash.ReportComboBox.SelectedItem.Text)
    Switch ($uiHash.ReportComboBox.SelectedItem.Text) {
        "Audit CSV Report" {
            If ($updateAudit.count -gt 0) { 
                $uiHash.StatusTextBox.Foreground = "Black"
                $savedreport = Join-Path $reportpath "AuditReport.csv"
                $updateAudit | Export-Csv $savedreport -NoTypeInformation
                $uiHash.StatusTextBox.Text = "Report saved to $savedreport"
                } Else {
                $uiHash.StatusTextBox.Foreground = "Red"
                $uiHash.StatusTextBox.Text = "No report to create!"         
            }         
        }
        "Audit UI Report" {
            If ($updateAudit.count -gt 0) {
                $updateAudit | Out-GridView -Title 'Audit Report'
            } Else {
                $uiHash.StatusTextBox.Foreground = "Red"
                $uiHash.StatusTextBox.Text = "No report to create!"         
            }
        }
        "Install CSV Report" {
            If ($installAudit.count -gt 0) { 
                $uiHash.StatusTextBox.Foreground = "Black"
                $savedreport = Join-Path $reportpath "InstallReport.csv"
                $installAudit | Export-Csv $savedreport -NoTypeInformation
                $uiHash.StatusTextBox.Text = "Report saved to $savedreport"
                } Else {
                $uiHash.StatusTextBox.Foreground = "Red"
                $uiHash.StatusTextBox.Text = "No report to create!"         
            }        
        }
        "Install UI Report" {
            If ($installAudit.count -gt 0) {
                $installAudit | Out-GridView -Title 'Install Report'
            } Else {
                $uiHash.StatusTextBox.Foreground = "Red"
                $uiHash.StatusTextBox.Text = "No report to create!"         
            }        
        }
        "Installed Updates CSV Report" {
            If ($installedUpdates.count -gt 0) { 
                $uiHash.StatusTextBox.Foreground = "Black"
                $savedreport = Join-Path $reportpath "InstalledUpdatesReport.csv"
                $installedUpdates | Export-Csv $savedreport -NoTypeInformation
                $uiHash.StatusTextBox.Text = "Report saved to $savedreport"
                } Else {
                $uiHash.StatusTextBox.Foreground = "Red"
                $uiHash.StatusTextBox.Text = "No report to create!"         
            }        
        }
        "Installed Updates UI Report" {
            If ($installedUpdates.count -gt 0) {
                $installedUpdates | Out-GridView -Title 'Installed Updates Report'
            } Else {
                $uiHash.StatusTextBox.Foreground = "Red"
                $uiHash.StatusTextBox.Text = "No report to create!"         
            }        
        }
        "Host File List" {
            If ($uiHash.Listview.Items.count -gt 0) { 
                $uiHash.StatusTextBox.Foreground = "Black"
                $savedreport = Join-Path $reportpath "hosts.txt"
                $uiHash.Listview.DataContext | Select -Expand Computer | Out-File $savedreport
                $uiHash.StatusTextBox.Text = "Report saved to $savedreport"
                } Else {
                $uiHash.StatusTextBox.Foreground = "Red"
                $uiHash.StatusTextBox.Text = "No report to create!"         
            }        
        }
        "Computer List Report" {
            If ($uiHash.Listview.Items.count -gt 0) {
                $uiHash.StatusTextBox.Foreground = "Black"
                $savedreport = Join-Path (Join-Path $home Desktop) "serverlist.csv"
                $uiHash.Listview.DataContext | Export-Csv -NoTypeInformation $savedreport
                $uiHash.StatusTextBox.Text = "Report saved to $savedreport"        
            } Else {
                $uiHash.StatusTextBox.Foreground = "Red"
                $uiHash.StatusTextBox.Text = "No report to create!"         
            }         
        }
        "Error UI Report" {Get-Error | Out-GridView -Title 'Error Report'}
        "Services UI Report" {
            If (@($servicesAudit).count -gt 0) {
                $servicesAudit | Select @{L='Computername';E={$_.__Server}},Name,DisplayName,State,StartMode,ExitCode,Status | Out-GridView -Title 'Services Report'
            } Else {
                $uiHash.StatusTextBox.Foreground = "Red"
                $uiHash.StatusTextBox.Text = "No report to create!"             
            }
        }
        "Services CSV Report" {
            If (@($servicesAudit).count -gt 0) { 
                $uiHash.StatusTextBox.Foreground = "Black"
                $savedreport = Join-Path $reportpath "ServicesReport.csv"
                $servicesAudit | Select @{L='Computername';E={$_.__Server}},Name,DisplayName,State,StartMode,ExitCode,Status | Export-Csv $savedreport -NoTypeInformation
                $uiHash.StatusTextBox.Text = "Report saved to $savedreport"
                } Else {
                $uiHash.StatusTextBox.Foreground = "Red"
                $uiHash.StatusTextBox.Text = "No report to create!"         
            }         
        }
    }
}

#start-RunJob function
Function Start-RunJob {    
    Write-Debug ("ComboBox {0}" -f $uiHash.RunOptionComboBox.Text)
    $selectedItems = $uiHash.Listview.SelectedItems
    If ($selectedItems.Count -gt 0) {
        $uiHash.ProgressBar.Maximum = $selectedItems.count
        $uiHash.Listview.ItemsSource | ForEach {$_.Notes = $Null}        
        If ($uiHash.RunOptionComboBox.Text -eq 'Install Patches') {             
            #region Install Patches
            $uiHash.RunButton.IsEnabled = $False
            $uiHash.StartImage.Source = "$pwd\Images\Start_locked.jpg"
            $uiHash.CancelButton.IsEnabled = $True
            $uiHash.CancelImage.Source = "$pwd\Images\Stop.jpg"            
            $uiHash.StatusTextBox.Foreground = "Black"
            $uiHash.StatusTextBox.Text = "Installing Patches for all servers...Please Wait"              
            $uiHash.StartTime = (Get-Date)
            
            [Float]$uiHash.ProgressBar.Value = 0
            $scriptBlock = {
                Param (
                    $Path,
                    $Computer,
                    $installAudit,
                    $uiHash
                )
                $uiHash.ListView.Dispatcher.Invoke("Normal",[action]{ 
                    $uiHash.Listview.Items.EditItem($Computer)
                    $computer.Notes = "Installing Patches"
                    $uiHash.Listview.Items.CommitEdit()
                    $uiHash.Listview.Items.Refresh() 
                })  
                Set-Location $path   
                . .\Scripts\Install-Patches.ps1                
                $clientInstall = @(Install-Patches -Computername $computer.computer)
                $installAudit.AddRange($clientInstall) | Out-Null
                $clientInstalledCount =  @($clientInstall | Where {$_.Notes -notmatch "Failed to Install Patch|ERROR"}).Count
                $clientInstalledErrorCount = @($clientInstall | Where {$_.Notes -match "Failed to Install Patch|ERROR"}).Count
                $uiHash.ListView.Dispatcher.Invoke("Normal",[action]{
                    $uiHash.Listview.Items.EditItem($Computer)
                    If ($clientInstall[0].Title -eq "NA") {                        
                        $Computer.Installed = 0                        
                    } Else {
                        $Computer.Installed = $clientInstalledCount
                        $Computer.InstallErrors = $clientInstalledErrorCount
                    }
                    $Computer.Notes = "Completed"
                    $uiHash.Listview.Items.CommitEdit()
                    $uiHash.Listview.Items.Refresh()
                })
                $uiHash.ProgressBar.Dispatcher.Invoke("Normal",[action]{
                    $uiHash.ProgressBar.value++  
                })
                $uiHash.Window.Dispatcher.Invoke("Normal",[action]{
                    #Check to see if find job
                    If ($uiHash.ProgressBar.value -eq $uiHash.ProgressBar.Maximum) {    
                        $End = New-Timespan $uihash.StartTime (Get-Date)                                             
                        $uiHash.StatusTextBox.Text = ("Completed in {0}" -f $end)                                     
                        $uiHash.RunButton.IsEnabled = $True
                        $uiHash.StartImage.Source = "$pwd\Images\Start.jpg"
                        $uiHash.CancelButton.IsEnabled = $False
                        $uiHash.CancelImage.Source = "$pwd\Images\Stop_locked.jpg"                    
                    }
                })                  
            }

            Write-Verbose ("Creating runspace pool and session states")
            $sessionstate = [system.management.automation.runspaces.initialsessionstate]::CreateDefault()
            $runspaceHash.runspacepool = [runspacefactory]::CreateRunspacePool(1, $maxConcurrentJobs, $sessionstate, $Host)
            $runspaceHash.runspacepool.Open()  

            ForEach ($Computer in $selectedItems) {
                $uiHash.Listview.Items.EditItem($Computer)
                $computer.Notes = "Pending Patch Install"
                $uiHash.Listview.Items.CommitEdit()
                $uiHash.Listview.Items.Refresh() 
                #Create the powershell instance and supply the scriptblock with the other parameters 
                $powershell = [powershell]::Create().AddScript($ScriptBlock).AddArgument($Path).AddArgument($computer).AddArgument($installAudit).AddArgument($uiHash)
           
                #Add the runspace into the powershell instance
                $powershell.RunspacePool = $runspaceHash.runspacepool
           
                #Create a temporary collection for each runspace
                $temp = "" | Select-Object PowerShell,Runspace,Computer
                $Temp.Computer = $Computer.computer
                $temp.PowerShell = $powershell
           
                #Save the handle output when calling BeginInvoke() that will be used later to end the runspace
                $temp.Runspace = $powershell.BeginInvoke()
                Write-Verbose ("Adding {0} collection" -f $temp.Computer)
                $jobs.Add($temp) | Out-Null                
            }#endregion  
        } ElseIf ($uiHash.RunOptionComboBox.Text -eq 'Audit Patches') {
            #region Audit Patches
            $uiHash.RunButton.IsEnabled = $False
            $uiHash.StartImage.Source = "$pwd\Images\Start_locked.jpg"
            $uiHash.CancelButton.IsEnabled = $True
            $uiHash.CancelImage.Source = "$pwd\Images\Stop.jpg"            
            $uiHash.StatusTextBox.Foreground = "Black"
            $uiHash.StatusTextBox.Text = "Auditing Patches for all servers...Please Wait"            
            $Global:updatelayout = [Windows.Input.InputEventHandler]{ $uiHash.ProgressBar.UpdateLayout() }
            $uiHash.StartTime = (Get-Date)
            
            [Float]$uiHash.ProgressBar.Value = 0
            $scriptBlock = {
                Param (
                    $Path,
                    $Computer,
                    $updateAudit,
                    $uiHash
                )
                $uiHash.ListView.Dispatcher.Invoke("Normal",[action]{ 
                    $uiHash.Listview.Items.EditItem($Computer)
                    $computer.Notes = "Auditing Patches"
                    $uiHash.Listview.Items.CommitEdit()
                    $uiHash.Listview.Items.Refresh() 
                })  
                Set-Location $path
                . .\Scripts\Get-PendingUpdates.ps1                
                $clientUpdate = @(Get-PendingUpdates -Computer $computer.computer)

                $updateAudit.AddRange($clientUpdate) | Out-Null

                $uiHash.ListView.Dispatcher.Invoke("Normal",[action]{
                    $uiHash.Listview.Items.EditItem($Computer)
                    If ($clientUpdate[0].Title -eq "NA") {                        
                        $Computer.Audited = 0
                        $Computer.Notes = "Completed"
                    } ElseIf ($clientUpdate[0].Title -eq "ERROR") {
                        $Computer.Audited = 0
                        $Computer.Notes = "Error with Audit"
                    } ElseIf ($clientUpdate[0].Title -eq "OFFLINE") {
                        $Computer.Audited = 0
                        $Computer.Notes = "Offline"
                    } Else {
                        $Computer.Audited = $clientUpdate.Count
                        $Computer.Notes = "Completed"
                    }
                    $uiHash.Listview.Items.CommitEdit()
                    $uiHash.Listview.Items.Refresh()
                })
                $uiHash.ProgressBar.Dispatcher.Invoke("Normal",[action]{
                    $uiHash.ProgressBar.value++ 
                }) 
                    
                $uiHash.Window.Dispatcher.Invoke("Normal",[action]{
                    #Check to see if find job
                    If ($uiHash.ProgressBar.value -eq $uiHash.ProgressBar.Maximum) {    
                        $End = New-Timespan $uihash.StartTime (Get-Date)                                             
                        $uiHash.StatusTextBox.Text = ("Completed in {0}" -f $end)                                     
                        $uiHash.RunButton.IsEnabled = $True
                        $uiHash.StartImage.Source = "$pwd\Images\Start.jpg"
                        $uiHash.CancelButton.IsEnabled = $False
                        $uiHash.CancelImage.Source = "$pwd\Images\Stop_locked.jpg"                    
                    }
                })  
                
            }

            Write-Verbose ("Creating runspace pool and session states")
            $sessionstate = [system.management.automation.runspaces.initialsessionstate]::CreateDefault()
            $runspaceHash.runspacepool = [runspacefactory]::CreateRunspacePool(1, $maxConcurrentJobs, $sessionstate, $Host)
            $runspaceHash.runspacepool.Open()    

            ForEach ($Computer in $selectedItems) {
                $uiHash.Listview.Items.EditItem($Computer)
                $computer.Notes = "Pending Patch Audit"
                $uiHash.Listview.Items.CommitEdit()
                $uiHash.Listview.Items.Refresh() 
                #Create the powershell instance and supply the scriptblock with the other parameters 
                $powershell = [powershell]::Create().AddScript($ScriptBlock).AddArgument($Path).AddArgument($computer).AddArgument($updateAudit).AddArgument($uiHash)
           
                #Add the runspace into the powershell instance
                $powershell.RunspacePool = $runspaceHash.runspacepool
           
                #Create a temporary collection for each runspace
                $temp = "" | Select-Object PowerShell,Runspace,Computer
                $Temp.Computer = $Computer.computer
                $temp.PowerShell = $powershell
           
                #Save the handle output when calling BeginInvoke() that will be used later to end the runspace
                $temp.Runspace = $powershell.BeginInvoke()
                Write-Verbose ("Adding {0} collection" -f $temp.Computer)
                $jobs.Add($temp) | Out-Null                
            }#endregion                 
        } ElseIf ($uiHash.RunOptionComboBox.Text -eq 'Reboot Systems') {
            #region Reboot
            If ((Show-RebootWarning) -eq "Yes") {
                $uiHash.RunButton.IsEnabled = $False
                $uiHash.StartImage.Source = "$pwd\Images\Start_locked.jpg"
                $uiHash.CancelButton.IsEnabled = $True
                $uiHash.CancelImage.Source = "$pwd\Images\Stop.jpg"            
                $uiHash.StatusTextBox.Foreground = "Black"
                $uiHash.StatusTextBox.Text = "Rebooting Servers..."            
                $uiHash.StartTime = (Get-Date)
            
                [Float]$uiHash.ProgressBar.Value = 0
                $scriptBlock = {
                    Param (
                        $Computer,
                        $uiHash,
                        $Path
                    )               
                    $uiHash.ListView.Dispatcher.Invoke("Normal",[action]{ 
                        $uiHash.Listview.Items.EditItem($Computer)
                        $computer.Notes = "Rebooting"
                        $uiHash.Listview.Items.CommitEdit()
                        $uiHash.Listview.Items.Refresh() 
                    })                
                    Set-Location $Path
                    If (Test-Connection -Computer $Computer.computer -count 1 -Quiet) {
                        Try {
                            Restart-Computer 10.199.208.191 $Computer.computer -Force -ea stop
                            Do {
                                Start-Sleep -Seconds 2
                                Write-Verbose ("Waiting for {0} to shutdown..." -f $Computer.computer)
                            }
                            While ((Test-Connection -ComputerName $Computer.computer -Count 1 -Quiet))    
                            Do {
                                Start-Sleep -Seconds 5
                                $i++        
                                Write-Verbose ("{0} down...{1}" -f $Computer.computer, $i)
                                If($i -eq 60) {
                                    Write-Warning ("{0} did not come back online from reboot!" -f $Computer.computer)
                                    $connection = $False
                                }
                            }
                            While (-NOT(Test-Connection -ComputerName $Computer.computer -Count 1 -Quiet))
                            Write-Verbose ("{0} is back up" -f $Computer.computer)
                            $connection = $True
                        } Catch {
                            Write-Warning "$($Error[0])"
                            $connection = $False
                        }
                    }

                    $uiHash.ListView.Dispatcher.Invoke("Normal",[action]{                    
                        $uiHash.Listview.Items.EditItem($Computer)
                        If ($Connection) {
                            $Computer.Notes = "Online"
                        } ElseIf (-Not $Connection) {
                            $Computer.Notes = "Offline"
                        } Else {
                            $Computer.Notes = "Unknown"
                        } 
                        $uiHash.Listview.Items.CommitEdit()
                        $uiHash.Listview.Items.Refresh()
                    })
                    $uiHash.ProgressBar.Dispatcher.Invoke("Normal",[action]{   
                        $uiHash.ProgressBar.value++  
                    })
                    $uiHash.Window.Dispatcher.Invoke("Normal",[action]{   
                        #Check to see if find job
                        If ($uiHash.ProgressBar.value -eq $uiHash.ProgressBar.Maximum) { 
                            $End = New-Timespan $uihash.StartTime (Get-Date)                                             
                            $uiHash.StatusTextBox.Text = ("Completed in {0}" -f $end)
                            $uiHash.RunButton.IsEnabled = $True
                            $uiHash.StartImage.Source = "$pwd\Images\Start.jpg"
                            $uiHash.CancelButton.IsEnabled = $False
                            $uiHash.CancelImage.Source = "$pwd\Images\Stop_locked.jpg"                    
                        }
                    })  
                
                }

            Write-Verbose ("Creating runspace pool and session states")
            $sessionstate = [system.management.automation.runspaces.initialsessionstate]::CreateDefault()
            $runspaceHash.runspacepool = [runspacefactory]::CreateRunspacePool(1, $maxRebootJobs, $sessionstate, $Host)
            $runspaceHash.runspacepool.Open()  

                ForEach ($Computer in $selectedItems) {
                    $uiHash.Listview.Items.EditItem($Computer)
                    $computer.Notes = "Pending Reboot"
                    $uiHash.Listview.Items.CommitEdit()
                    $uiHash.Listview.Items.Refresh() 
                    #Create the powershell instance and supply the scriptblock with the other parameters 
                    $powershell = [powershell]::Create().AddScript($ScriptBlock).AddArgument($computer).AddArgument($uiHash).AddArgument($Path)
           
                    #Add the runspace into the powershell instance
                    $powershell.RunspacePool = $runspaceHash.runspacepool
           
                    #Create a temporary collection for each runspace
                    $temp = "" | Select-Object PowerShell,Runspace,Computer
                    $Temp.Computer = $Computer.computer
                    $temp.PowerShell = $powershell
           
                    #Save the handle output when calling BeginInvoke() that will be used later to end the runspace
                    $temp.Runspace = $powershell.BeginInvoke()
                    Write-Verbose ("Adding {0} collection" -f $temp.Computer)
                    $jobs.Add($temp) | Out-Null
                }                
            }#endregion           
        } ElseIf ($uiHash.RunOptionComboBox.Text -eq 'Ping Sweep') {
            #region PingSweeps
            $uiHash.RunButton.IsEnabled = $False
            $uiHash.StartImage.Source = "$pwd\Images\Start_locked.jpg"
            $uiHash.CancelButton.IsEnabled = $True
            $uiHash.CancelImage.Source = "$pwd\Images\Stop.jpg"            
            $uiHash.StatusTextBox.Foreground = "Black"
            $uiHash.StatusTextBox.Text = "Checking server connection..."            
            $uiHash.StartTime = (Get-Date)
            
            [Float]$uiHash.ProgressBar.Value = 0
            $scriptBlock = {
                Param (
                    $Computer,
                    $uiHash,
                    $Path
                )               
                $uiHash.ListView.Dispatcher.Invoke("Normal",[action]{ 
                    $uiHash.Listview.Items.EditItem($Computer)
                    $computer.Notes = "Checking connection"
                    $uiHash.Listview.Items.CommitEdit()
                    $uiHash.Listview.Items.Refresh() 
                })                
                Set-Location $Path
                $Connection = (Test-Connection -ComputerName $Computer.computer -Count 1 -Quiet)
                $uiHash.ListView.Dispatcher.Invoke("Background",[action]{                    
                    $uiHash.Listview.Items.EditItem($Computer)
                    If ($Connection) {
                        $Computer.Notes = "Online"
                    } ElseIf (-Not $Connection) {
                        $Computer.Notes = "Offline"
                    } Else {
                        $Computer.Notes = "Unknown"
                    } 
                    $uiHash.Listview.Items.CommitEdit()
                    $uiHash.Listview.Items.Refresh()
                })
                $uiHash.ProgressBar.Dispatcher.Invoke("Normal",[action]{   
                    $uiHash.ProgressBar.value++  
                })
                $uiHash.Window.Dispatcher.Invoke("Normal",[action]{   
                    #Check to see if find job
                    If ($uiHash.ProgressBar.value -eq $uiHash.ProgressBar.Maximum) { 
                        $End = New-Timespan $uihash.StartTime (Get-Date)                                             
                        $uiHash.StatusTextBox.Text = ("Completed in {0}" -f $end)
                        $uiHash.RunButton.IsEnabled = $True
                        $uiHash.StartImage.Source = "$pwd\Images\Start.jpg"
                        $uiHash.CancelButton.IsEnabled = $False
                        $uiHash.CancelImage.Source = "$pwd\Images\Stop_locked.jpg"                    
                    }
                })  
                
            }

            Write-Verbose ("Creating runspace pool and session states")
            $sessionstate = [system.management.automation.runspaces.initialsessionstate]::CreateDefault()
            $runspaceHash.runspacepool = [runspacefactory]::CreateRunspacePool(1, $maxConcurrentJobs, $sessionstate, $Host)
            $runspaceHash.runspacepool.Open()   

            ForEach ($Computer in $selectedItems) {
                $uiHash.Listview.Items.EditItem($Computer)
                $computer.Notes = "Pending Network Test"
                $uiHash.Listview.Items.CommitEdit()
                $uiHash.Listview.Items.Refresh() 
                #Create the powershell instance and supply the scriptblock with the other parameters 
                $powershell = [powershell]::Create().AddScript($ScriptBlock).AddArgument($computer).AddArgument($uiHash).AddArgument($Path)
           
                #Add the runspace into the powershell instance
                $powershell.RunspacePool = $runspaceHash.runspacepool
           
                #Create a temporary collection for each runspace
                $temp = "" | Select-Object PowerShell,Runspace,Computer
                $Temp.Computer = $Computer.computer
                $temp.PowerShell = $powershell
           
                #Save the handle output when calling BeginInvoke() that will be used later to end the runspace
                $temp.Runspace = $powershell.BeginInvoke()
                Write-Verbose ("Adding {0} collection" -f $temp.Computer)
                $jobs.Add($temp) | Out-Null                
            }
            #endregion           
        } ElseIf ($uiHash.RunOptionComboBox.Text -eq 'Check Pending Reboot') {
            #region Check Pending Reboot
            $uiHash.RunButton.IsEnabled = $False
            $uiHash.StartImage.Source = "$pwd\Images\Start_locked.jpg"
            $uiHash.CancelButton.IsEnabled = $True
            $uiHash.CancelImage.Source = "$pwd\Images\Stop.jpg"            
            $uiHash.StatusTextBox.Foreground = "Black"
            $uiHash.StatusTextBox.Text = "Checking for servers with a pending reboot..."            
            $uiHash.StartTime = (Get-Date)
            
            [Float]$uiHash.ProgressBar.Value = 0
            $scriptBlock = {
                Param (
                    $Computer,
                    $uiHash,
                    $Path
                )               
                $uiHash.ListView.Dispatcher.Invoke("Normal",[action]{ 
                    $uiHash.Listview.Items.EditItem($Computer)
                    $computer.Notes = "Checking for pending reboot"
                    $uiHash.Listview.Items.CommitEdit()
                    $uiHash.Listview.Items.Refresh() 
                })                
                Set-Location $Path
                . .\Scripts\Get-ComputerRebootState.ps1
                $clientRebootRequired = Get-ComputerRebootState -Computer $Computer.computer
                $uiHash.ListView.Dispatcher.Invoke("Background",[action]{                    
                    $uiHash.Listview.Items.EditItem($Computer)
                    If ($clientRebootRequired.RebootRequired -eq $True) {
                        $Computer.Notes = "Reboot Required"
                    } ElseIf ($clientRebootRequired.RebootRequired -eq $False) {
                        $Computer.Notes = "No Reboot Required"
                    } ElseIf ($clientRebootRequired.RebootRequired -eq "NA") {
                        $Computer.Notes = "Unable to determine reboot state"
                    } ElseIf ($clientRebootRequired.RebootRequired -eq "Offline") {
                        $Computer.Notes = "Offline"
                    }  
                    $uiHash.Listview.Items.CommitEdit()
                    $uiHash.Listview.Items.Refresh()
                })
                $uiHash.ProgressBar.Dispatcher.Invoke("Normal",[action]{   
                    $uiHash.ProgressBar.value++  
                })
                $uiHash.Window.Dispatcher.Invoke("Normal",[action]{   
                    #Check to see if find job
                    If ($uiHash.ProgressBar.value -eq $uiHash.ProgressBar.Maximum) { 
                        $End = New-Timespan $uihash.StartTime (Get-Date)                                             
                        $uiHash.StatusTextBox.Text = ("Completed in {0}" -f $end)
                        $uiHash.RunButton.IsEnabled = $True
                        $uiHash.StartImage.Source = "$pwd\Images\Start.jpg"
                        $uiHash.CancelButton.IsEnabled = $False
                        $uiHash.CancelImage.Source = "$pwd\Images\Stop_locked.jpg"                    
                    }
                })  
                
            }

            Write-Verbose ("Creating runspace pool and session states")
            $sessionstate = [system.management.automation.runspaces.initialsessionstate]::CreateDefault()
            $runspaceHash.runspacepool = [runspacefactory]::CreateRunspacePool(1, $maxConcurrentJobs, $sessionstate, $Host)
            $runspaceHash.runspacepool.Open()    

            ForEach ($Computer in $selectedItems) {
                $uiHash.Listview.Items.EditItem($Computer)
                $computer.Notes = "Pending Reboot Check"
                $uiHash.Listview.Items.CommitEdit()
                $uiHash.Listview.Items.Refresh() 
                #Create the powershell instance and supply the scriptblock with the other parameters 
                $powershell = [powershell]::Create().AddScript($ScriptBlock).AddArgument($computer).AddArgument($uiHash).AddArgument($Path)
           
                #Add the runspace into the powershell instance
                $powershell.RunspacePool = $runspaceHash.runspacepool
           
                #Create a temporary collection for each runspace
                $temp = "" | Select-Object PowerShell,Runspace,Computer
                $Temp.Computer = $Computer.computer
                $temp.PowerShell = $powershell
           
                #Save the handle output when calling BeginInvoke() that will be used later to end the runspace
                $temp.Runspace = $powershell.BeginInvoke()
                Write-Verbose ("Adding {0} collection" -f $temp.Computer)
                $jobs.Add($temp) | Out-Null                
            }#endregion                
        } ElseIf ($uiHash.RunOptionComboBox.Text -eq 'Services Check') {
            #region Check Services
            $uiHash.RunButton.IsEnabled = $False
            $uiHash.StartImage.Source = "$pwd\Images\Start_locked.jpg"
            $uiHash.CancelButton.IsEnabled = $True
            $uiHash.CancelImage.Source = "$pwd\Images\Stop.jpg"            
            $uiHash.StatusTextBox.Foreground = "Black"
            $uiHash.StatusTextBox.Text = "Checking for Non-Running Automatic Services..."            
            $uiHash.StartTime = (Get-Date)
            
            [Float]$uiHash.ProgressBar.Value = 0
            $scriptBlock = {
                Param (
                    $Computer,
                    $uiHash,
                    $Path,
                    $servicesAudit
                )               
                $uiHash.ListView.Dispatcher.Invoke("Normal",[action]{ 
                    $uiHash.Listview.Items.EditItem($Computer)
                    $computer.Notes = "Checking for non-running services set to Auto"
                    $uiHash.Listview.Items.CommitEdit()
                    $uiHash.Listview.Items.Refresh() 
                })                
                Clear-Variable queryError -ErrorAction SilentlyContinue
                Set-Location $Path
                If (Test-Connection -ComputerName $computer.computer -Count 1 -Quiet) {
                    Try {
                        $wmi = @{
                            ErrorAction = 'Stop'
                            Computername = $computer.computer
                            Query = "Select __Server,Name,DisplayName,State,StartMode,ExitCode,Status FROM Win32_Service WHERE StartMode='Auto' AND State!='Running'"
                        }
                        $services = @(Get-WmiObject @wmi)
                    } Catch {
                        $queryError = $_.Exception.Message
                    }
                } Else {
                    $queryError = "Offline"
                }
                If ($services.count -gt 0) {
                    $servicesAudit.AddRange($services) | Out-Null
                }
                $uiHash.ListView.Dispatcher.Invoke("Background",[action]{                    
                    $uiHash.Listview.Items.EditItem($Computer)
                    $Computer.Services = $services.count
                    If ($queryError) {
                        $Computer.notes = $queryError
                    } Else {
                        $Computer.notes = 'Completed'
                    }
                    $uiHash.Listview.Items.CommitEdit()
                    $uiHash.Listview.Items.Refresh()
                })
                $uiHash.ProgressBar.Dispatcher.Invoke("Normal",[action]{   
                    $uiHash.ProgressBar.value++  
                })
                $uiHash.Window.Dispatcher.Invoke("Normal",[action]{   
                    #Check to see if find job
                    If ($uiHash.ProgressBar.value -eq $uiHash.ProgressBar.Maximum) { 
                        $End = New-Timespan $uihash.StartTime (Get-Date)                                             
                        $uiHash.StatusTextBox.Text = ("Completed in {0}" -f $end)
                        $uiHash.RunButton.IsEnabled = $True
                        $uiHash.StartImage.Source = "$pwd\Images\Start.jpg"
                        $uiHash.CancelButton.IsEnabled = $False
                        $uiHash.CancelImage.Source = "$pwd\Images\Stop_locked.jpg"                    
                    }
                })  
                
            }

            Write-Verbose ("Creating runspace pool and session states")
            $sessionstate = [system.management.automation.runspaces.initialsessionstate]::CreateDefault()
            $runspaceHash.runspacepool = [runspacefactory]::CreateRunspacePool(1, $maxConcurrentJobs, $sessionstate, $Host)
            $runspaceHash.runspacepool.Open()    

            ForEach ($Computer in $selectedItems) {
                $uiHash.Listview.Items.EditItem($Computer)
                $computer.Notes = "Pending Service Check"
                $uiHash.Listview.Items.CommitEdit()
                $uiHash.Listview.Items.Refresh() 
                #Create the powershell instance and supply the scriptblock with the other parameters 
                $powershell = [powershell]::Create().AddScript($ScriptBlock).AddArgument($computer).AddArgument($uiHash).AddArgument($Path).AddArgument($servicesAudit)
           
                #Add the runspace into the powershell instance
                $powershell.RunspacePool = $runspaceHash.runspacepool
           
                #Create a temporary collection for each runspace
                $temp = "" | Select-Object PowerShell,Runspace,Computer
                $Temp.Computer = $Computer.computer
                $temp.PowerShell = $powershell
           
                #Save the handle output when calling BeginInvoke() that will be used later to end the runspace
                $temp.Runspace = $powershell.BeginInvoke()
                Write-Verbose ("Adding {0} collection" -f $temp.Computer)
                $jobs.Add($temp) | Out-Null                
            }#endregion
        }                                  
    }  Else {
        $uiHash.StatusTextBox.Foreground = "Red"
        $uiHash.StatusTextBox.Text = "No server/s selected!"
    }  
}

Function Open-FileDialog {
    $dlg = new-object microsoft.win32.OpenFileDialog
    $dlg.DefaultExt = "*.txt"
    $dlg.Filter = "Text Files |*.txt;*.log"    
    $dlg.InitialDirectory = $path
    [void]$dlg.showdialog()
    Write-Output $dlg.FileName
}

Function Open-DomainDialog {
    $domain = [Microsoft.VisualBasic.Interaction]::InputBox("Enter the LDAP path for the Domain or press OK to use the default domain.", 
    "Domain Query", "$(([adsisearcher]'').SearchRoot.distinguishedName)")  
    If (-Not [string]::IsNullOrEmpty($domain)) {
        Write-Output $domain
    }
}

#Build the GUI
[xml]$xaml = @"
<Window
    xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'
    xmlns:x='http://schemas.microsoft.com/winfx/2006/xaml'
    x:Name='Window' Title='PowerShell Patch/Audit Utility' WindowStartupLocation = 'CenterScreen' 
    Width = '880' Height = '575' ShowInTaskbar = 'True'>
    <Window.Background>
        <LinearGradientBrush StartPoint='0,0' EndPoint='0,1'>
            <LinearGradientBrush.GradientStops> <GradientStop Color='#C4CBD8' Offset='0' /> <GradientStop Color='#E6EAF5' Offset='0.2' /> 
            <GradientStop Color='#CFD7E2' Offset='0.9' /> <GradientStop Color='#C4CBD8' Offset='1' /> </LinearGradientBrush.GradientStops>
        </LinearGradientBrush>
    </Window.Background> 
    <Window.Resources>        
        <DataTemplate x:Key="HeaderTemplate">
            <DockPanel>
                <TextBlock FontSize="10" Foreground="Green" FontWeight="Bold" >
                    <TextBlock.Text>
                        <Binding/>
                    </TextBlock.Text>
                </TextBlock>
            </DockPanel>
        </DataTemplate>            
    </Window.Resources>    
    <Grid x:Name = 'Grid' ShowGridLines = 'false'>
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="*"/>
        </Grid.ColumnDefinitions>
        <Grid.RowDefinitions>
            <RowDefinition Height = 'Auto'/>
            <RowDefinition Height = 'Auto'/>
            <RowDefinition Height = '*'/>
            <RowDefinition Height = 'Auto'/>
            <RowDefinition Height = 'Auto'/>
            <RowDefinition Height = 'Auto'/>
        </Grid.RowDefinitions>    
        <Menu Width = 'Auto' HorizontalAlignment = 'Stretch' Grid.Row = '0'>
        <Menu.Background>
            <LinearGradientBrush StartPoint='0,0' EndPoint='0,1'>
                <LinearGradientBrush.GradientStops> <GradientStop Color='#C4CBD8' Offset='0' /> <GradientStop Color='#E6EAF5' Offset='0.2' /> 
                <GradientStop Color='#CFD7E2' Offset='0.9' /> <GradientStop Color='#C4CBD8' Offset='1' /> </LinearGradientBrush.GradientStops>
            </LinearGradientBrush>
        </Menu.Background>
            <MenuItem x:Name = 'FileMenu' Header = '_File'>
                <MenuItem x:Name = 'RunMenu' Header = '_Run' ToolTip = 'Initiate Run operation' InputGestureText ='F5'> </MenuItem>
                <MenuItem x:Name = 'GenerateReportMenu' Header = 'Generate R_eport' ToolTip = 'Generate Report' InputGestureText ='F8'/>
                <Separator />            
                <MenuItem x:Name = 'OptionMenu' Header = '_Options' ToolTip = 'Open up options window.' InputGestureText ='Ctrl+O'/>
                <Separator />
                <MenuItem x:Name = 'ExitMenu' Header = 'E_xit' ToolTip = 'Exits the utility.' InputGestureText ='Ctrl+E'/>
            </MenuItem>
            <MenuItem x:Name = 'EditMenu' Header = '_Edit'>
                <MenuItem x:Name = 'SelectAllMenu' Header = 'Select _All' ToolTip = 'Selects all rows.' InputGestureText ='Ctrl+A'/>               
                <Separator />
                <MenuItem x:Name = 'ClearErrorMenu' Header = 'Clear ErrorLog' ToolTip = 'Clears error log.'> </MenuItem>                
                <MenuItem x:Name = 'ClearAllMenu' Header = 'Clear All' ToolTip = 'Clears everything on the 31.39.1.252 utility.'/>
            </MenuItem>
            <MenuItem x:Name = 'ActionMenu' Header = '_Action'>
                <MenuItem Header = 'Reports'>
                    <MenuItem x:Name = 'ClearAuditReportMenu' Header = 'Clear Audit Report' ToolTip = 'Clears the current report.'/>
                    <MenuItem x:Name = 'ClearInstallReportMenu' Header = 'Clear Install Report' ToolTip = 'Clears the current report.'/>                   
                    <MenuItem x:Name = 'ClearInstalledUpdateMenu' Header = 'Clear Installed Update Report' ToolTip = 'Clears the installed update report.'/>
                </MenuItem>
                <MenuItem Header = 'Server List'>
                    <MenuItem x:Name = 'ClearServerListMenu' Header = 'Clear Server List' ToolTip = 'Clears the server list.'/>
                    <MenuItem x:Name = 'ClearServerListNotesMenu' Header = 'Clear Server List Notes' ToolTip = 'Clears the server list notes column.'/>
                    <MenuItem x:Name = 'OfflineHostsMenu' Header = 'Remove Offline Servers' ToolTip = 'Removes all offline hosts from Server List'/>                   
                    <MenuItem x:Name = 'ResetDataMenu' Header = 'Reset Computer List Data' ToolTip = 'Resets the audit and patch data on Server List'/>
                </MenuItem> 
            <Separator />                           
            <MenuItem x:Name = 'HostListMenu' Header = 'Create Host List' ToolTip = 'Creates a list of all servers and saves to a text file.'/>
                <MenuItem x:Name = 'ServerListReportMenu' Header = 'Create Server List Report' 
                ToolTip = 'Creates a CSV file listing the current Server List.'/>
                <Separator/>
                <MenuItem x:Name = 'ViewErrorMenu' Header = 'View ErrorLog' ToolTip = 'Clears error log.'/>            
            </MenuItem>            
            <MenuItem x:Name = 'HelpMenu' Header = '_Help'>
                <MenuItem x:Name = 'AboutMenu' Header = '_About' ToolTip = 'Show the current version and other information.'> </MenuItem>
                <MenuItem x:Name = 'HelpFileMenu' Header = '31.39.1.252 Utility _Help' 
                ToolTip = 'Displays a help file to use the 31.39.1.252 Utility.' InputGestureText ='F1'> </MenuItem>
            </MenuItem>            
        </Menu>
        <ToolBarTray Grid.Row = '1' Grid.Column = '0'>
        <ToolBarTray.Background>
            <LinearGradientBrush StartPoint='0,0' EndPoint='0,1'>
                <LinearGradientBrush.GradientStops> <GradientStop Color='#C4CBD8' Offset='0' /> <GradientStop Color='#E6EAF5' Offset='0.2' /> 
                <GradientStop Color='#CFD7E2' Offset='0.9' /> <GradientStop Color='#C4CBD8' Offset='1' /> </LinearGradientBrush.GradientStops>
            </LinearGradientBrush>        
        </ToolBarTray.Background>
            <ToolBar Background = 'Transparent' Band = '1' BandIndex = '1'>
                <Button x:Name = 'RunButton' Width = 'Auto' ToolTip = 'Performs action against all servers in the server list based on checked radio button.'>
                    <Image x:Name = 'StartImage' Source = '$Pwd\Images\Start.jpg'/>
                </Button>         
                <Separator Background = 'Black'/>   
                <Button x:Name = 'CancelButton' Width = 'Auto' ToolTip = 'Cancels currently running operations.' IsEnabled = 'False'>
                    <Image x:Name = 'CancelImage' Source = '$pwd\Images\Stop_locked.jpg' />
                </Button>
                <Separator Background = 'Black'/>
                <ComboBox x:Name = 'RunOptionComboBox' Width = 'Auto' IsReadOnly = 'True'
                SelectedIndex = '0'>
                    <TextBlock> Audit Patches </TextBlock>
                    <TextBlock> Install Patches </TextBlock>
                    <TextBlock> Check Pending Reboot </TextBlock>
                    <TextBlock> Ping Sweep </TextBlock>
                    <TextBlock> Services Check </TextBlock>
                    <TextBlock> Reboot Systems </TextBlock>
                </ComboBox>                
            </ToolBar>
            <ToolBar Background = 'Transparent' Band = '1' BandIndex = '1'>
                <Button x:Name = 'GenerateReportButton' Width = 'Auto' ToolTip = 'Generates a report based on user selection.'>
                    <Image Source = '$pwd\Images\Gen_Report.gif' />
                </Button>            
                <ComboBox x:Name = 'ReportComboBox' Width = 'Auto' IsReadOnly = 'True' SelectedIndex = '0'>
                    <TextBlock> Audit CSV Report </TextBlock>
                    <TextBlock> Audit UI Report </TextBlock>
                    <TextBlock> Install CSV Report </TextBlock>
                    <TextBlock> Install UI Report </TextBlock>
                    <TextBlock> Installed Updates CSV Report </TextBlock>
                    <TextBlock> Installed Updates UI Report </TextBlock>
                    <TextBlock> Services CSV Report </TextBlock> 
                    <TextBlock> Services UI Report </TextBlock>                                                           
                    <TextBlock> Host File List </TextBlock>
                    <TextBlock> Computer List Report </TextBlock>
                    <TextBlock> Error UI Report </TextBlock>
                </ComboBox>              
                <Separator Background = 'Black'/>
            </ToolBar>
            <ToolBar Background = 'Transparent' Band = '1' BandIndex = '1'>
                <Button x:Name = 'BrowseFileButton' Width = 'Auto' 
                ToolTip = 'Open a file dialog to select a host file. Upon selection, the contents will be loaded into Server list.'>
                    <Image Source = '$pwd\Images\BrowseFile.gif' />
                </Button>    
                <Button x:Name = 'LoadADButton' Width = 'Auto' 
                ToolTip = 'Creates a list of computers from Active Directory to use in Server List.'>
                    <Image Source = '$pwd\Images\ActiveDirectory.gif' />
                </Button>                                      
                <Separator Background = 'Black'/>
            </ToolBar>             
        </ToolBarTray>
        <Grid Grid.Row = '2' Grid.Column = '0' ShowGridLines = 'false'>  
            <Grid.Resources>
                <Style x:Key="AlternatingRowStyle" TargetType="{x:Type Control}" >
                    <Setter Property="Background" Value="LightGray"/>
                    <Setter Property="Foreground" Value="Black"/>
                    <Style.Triggers>
                        <Trigger Property="ItemsControl.AlternationIndex" Value="1">                            
                            <Setter Property="Background" Value="White"/>
                            <Setter Property="Foreground" Value="Black"/>                                
                        </Trigger>                            
                    </Style.Triggers>
                </Style>                    
            </Grid.Resources>                  
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="10"/>
                <ColumnDefinition Width="Auto"/>
                <ColumnDefinition Width="10"/>
                <ColumnDefinition Width="Auto"/>
                <ColumnDefinition Width="10"/>
                <ColumnDefinition Width="Auto"/>
            </Grid.ColumnDefinitions>
            <Grid.RowDefinitions>
                <RowDefinition Height = 'Auto'/>
                <RowDefinition Height = 'Auto'/>
                <RowDefinition Height = '*'/>
                <RowDefinition Height = '*'/>
                <RowDefinition Height = 'Auto'/>
                <RowDefinition Height = 'Auto'/>
                <RowDefinition Height = 'Auto'/>
            </Grid.RowDefinitions> 
            <GroupBox Header = "Computer List" Grid.Column = '0' Grid.Row = '2' Grid.ColumnSpan = '11' Grid.RowSpan = '3'>
                <Grid Width = 'Auto' Height = 'Auto' ShowGridLines = 'false'>
                <ListView x:Name = 'Listview' AllowDrop = 'True' AlternationCount="2" ItemContainerStyle="{StaticResource AlternatingRowStyle}"
                ToolTip = 'Server List that displays all information regarding statuses of servers and patches.'>
                    <ListView.View>
                        <GridView x:Name = 'GridView' AllowsColumnReorder = 'True' ColumnHeaderTemplate="{StaticResource HeaderTemplate}">
                            <GridViewColumn x:Name = 'ComputerColumn' Width = '110' DisplayMemberBinding = '{Binding Path = Computer}' Header='Computer'/>
                            <GridViewColumn x:Name = 'AuditedColumn' Width = '110' DisplayMemberBinding = '{Binding Path = Audited}' Header='Audited'/>                    
                            <GridViewColumn x:Name = 'InstalledColumn' Width = '110' DisplayMemberBinding = '{Binding Path = Installed}' Header='Installed' />                    
                            <GridViewColumn x:Name = 'InstallErrorColumn' Width = '110' DisplayMemberBinding = '{Binding Path = InstallErrors}' Header='InstallErrors'/>  
                            <GridViewColumn x:Name = 'ServicesColumn' Width = '115' DisplayMemberBinding = '{Binding Path = Services}' Header='NonRunningServices'/>                                                
                            <GridViewColumn x:Name = 'NotesColumn' Width = '275' DisplayMemberBinding = '{Binding Path = Notes}' Header='Notes'/>                    
                        </GridView>
                    </ListView.View>
                    <ListView.ContextMenu>
                        <ContextMenu x:Name = 'ListViewContextMenu'>
                            <MenuItem x:Name = 'AddServerMenu' Header = 'Add Server' InputGestureText ='Ctrl+S'/>               
                            <MenuItem x:Name = 'RemoveServerMenu' Header = 'Remove Server' InputGestureText ='Ctrl+D'/>
                            <Separator />
                            <MenuItem x:Name = 'WindowsUpdateServiceMenu' Header = 'Windows Update Service' > 
                                <MenuItem x:Name = 'WUStopServiceMenu' Header = 'Stop Service' />
                                <MenuItem x:Name = 'WUStartServiceMenu' Header = 'Start Service' />
                                <MenuItem x:Name = 'WURestartServiceMenu' Header = 'Restart Service' />
                            </MenuItem>                            
                            <MenuItem x:Name = 'WindowsUpdateLogMenu' Header = 'WindowsUpdateLog' > 
                                <MenuItem x:Name = 'EntireLogMenu' Header = 'View Entire Log'/>
                                <MenuItem x:Name = 'Last25LogMenu' Header = 'View Last 25' />
                                <MenuItem x:Name = 'Last50LogMenu' Header = 'View Last 50'/>
                                <MenuItem x:Name = 'Last100LogMenu' Header = 'View Last 100'/>
                            </MenuItem>
                            <MenuItem x:Name = 'WUAUCLTMenu' Header = 'WUAUCLT' >
                                <MenuItem x:Name = 'DetectNowMenu' Header = 'Run Detect Now'/> 
                                <MenuItem x:Name = 'ResetAuthorizationMenu' Header = 'Run Reset Authorization'/>
                            </MenuItem>                  
                            <MenuItem x:Name = 'InstalledUpdatesMenu' Header = 'Installed Updates' >
                                <MenuItem x:Name = 'GUIInstalledUpdatesMenu' Header = 'Get Installed Updates'/>
                            </MenuItem>
                        </ContextMenu>
                    </ListView.ContextMenu>            
                </ListView>                
                </Grid>
            </GroupBox>                                    
        </Grid>        
        <ProgressBar x:Name = 'ProgressBar' Grid.Row = '3' Height = '20' ToolTip = 'Displays progress of current action via a graphical progress bar.'/>   
        <TextBox x:Name = 'StatusTextBox' Grid.Row = '4' ToolTip = 'Displays current status of operation'> Waiting for Action... </TextBox>                           
    </Grid>   
</Window>
"@ 

#region Load XAML into PowerShell
$reader=(New-Object System.Xml.XmlNodeReader $xaml)
$uiHash.Window=[Windows.Markup.XamlReader]::Load( $reader )
#endregion
 
#region Background runspace to clean up jobs
$jobCleanup.Flag = $True
$newRunspace =[runspacefactory]::CreateRunspace()
$newRunspace.ApartmentState = "STA"
$newRunspace.ThreadOptions = "ReuseThread"          
$newRunspace.Open()
$newRunspace.SessionStateProxy.SetVariable("uiHash",$uiHash)          
$newRunspace.SessionStateProxy.SetVariable("jobCleanup",$jobCleanup)     
$newRunspace.SessionStateProxy.SetVariable("jobs",$jobs) 
$jobCleanup.PowerShell = [PowerShell]::Create().AddScript({
    #Routine to handle completed runspaces
    Do {    
        Foreach($runspace in $jobs) {
            If ($runspace.Runspace.isCompleted) {
                $runspace.powershell.EndInvoke($runspace.Runspace) | Out-Null
                $runspace.powershell.dispose()
                $runspace.Runspace = $null
                $runspace.powershell = $null               
            } 
        }
        #Clean out unused runspace jobs
        $temphash = $jobs.clone()
        $temphash | Where {
            $_.runspace -eq $Null
        } | ForEach {
            Write-Verbose ("Removing {0}" -f $_.computer)
            $jobs.remove($_)
        }        
        Start-Sleep -Seconds 1     
    } while ($jobCleanup.Flag)
})
$jobCleanup.PowerShell.Runspace = $newRunspace
$jobCleanup.Thread = $jobCleanup.PowerShell.BeginInvoke()  
#endregion

#region Connect to all controls
$uiHash.GenerateReportMenu = $uiHash.Window.FindName("GenerateReportMenu")
$uiHash.ClearAuditReportMenu = $uiHash.Window.FindName("ClearAuditReportMenu")
$uiHash.ClearInstallReportMenu = $uiHash.Window.FindName("ClearInstallReportMenu")
$uiHash.SelectAllMenu = $uiHash.Window.FindName("SelectAllMenu")
$uiHash.OptionMenu = $uiHash.Window.FindName("OptionMenu")
$uiHash.WUStopServiceMenu = $uiHash.Window.FindName("WUStopServiceMenu")
$uiHash.WUStartServiceMenu = $uiHash.Window.FindName("WUStartServiceMenu")
$uiHash.WURestartServiceMenu = $uiHash.Window.FindName("WURestartServiceMenu")
$uiHash.WindowsUpdateServiceMenu = $uiHash.Window.FindName("WindowsUpdateServiceMenu")
$uiHash.GenerateReportButton = $uiHash.Window.FindName("GenerateReportButton")
$uiHash.ReportComboBox = $uiHash.Window.FindName("ReportComboBox")
$uiHash.StartImage = $uiHash.Window.FindName("StartImage")
$uiHash.CancelImage = $uiHash.Window.FindName("CancelImage")
$uiHash.RunOptionComboBox = $uiHash.Window.FindName("RunOptionComboBox")
$uiHash.ClearErrorMenu = $uiHash.Window.FindName("ClearErrorMenu")
$uiHash.ViewErrorMenu = $uiHash.Window.FindName("ViewErrorMenu")
$uiHash.EntireLogMenu = $uiHash.Window.FindName("EntireLogMenu")
$uiHash.Last25LogMenu = $uiHash.Window.FindName("Last25LogMenu")
$uiHash.Last50LogMenu = $uiHash.Window.FindName("Last50LogMenu")
$uiHash.Last100LogMenu = $uiHash.Window.FindName("Last100LogMenu")
$uiHash.ResetDataMenu = $uiHash.Window.FindName("ResetDataMenu")
$uiHash.ResetAuthorizationMenu = $uiHash.Window.FindName("ResetAuthorizationMenu")
$uiHash.ClearServerListNotesMenu = $uiHash.Window.FindName("ClearServerListNotesMenu")
$uiHash.ServerListReportMenu = $uiHash.Window.FindName("ServerListReportMenu")
$uiHash.OfflineHostsMenu = $uiHash.Window.FindName("OfflineHostsMenu")
$uiHash.HostListMenu = $uiHash.Window.FindName("HostListMenu")
$uiHash.InstalledUpdatesMenu = $uiHash.Window.FindName("InstalledUpdatesMenu")
$uiHash.DetectNowMenu = $uiHash.Window.FindName("DetectNowMenu")
$uiHash.WindowsUpdateLogMenu = $uiHash.Window.FindName("WindowsUpdateLogMenu")
$uiHash.WUAUCLTMenu = $uiHash.Window.FindName("WUAUCLTMenu")
$uiHash.GUIInstalledUpdatesMenu = $uiHash.Window.FindName("GUIInstalledUpdatesMenu")
$uiHash.AddServerMenu = $uiHash.Window.FindName("AddServerMenu")
$uiHash.RemoveServerMenu = $uiHash.Window.FindName("RemoveServerMenu")
$uiHash.ListviewContextMenu = $uiHash.Window.FindName("ListViewContextMenu")
$uiHash.ExitMenu = $uiHash.Window.FindName("ExitMenu")
$uiHash.ClearInstalledUpdateMenu = $uiHash.Window.FindName("ClearInstalledUpdateMenu")
$uiHash.RunMenu = $uiHash.Window.FindName('RunMenu')
$uiHash.ClearAllMenu = $uiHash.Window.FindName("ClearAllMenu")
$uiHash.ClearServerListMenu = $uiHash.Window.FindName("ClearServerListMenu")
$uiHash.AboutMenu = $uiHash.Window.FindName("AboutMenu")
$uiHash.HelpFileMenu = $uiHash.Window.FindName("HelpFileMenu")
$uiHash.Listview = $uiHash.Window.FindName("Listview")
$uiHash.LoadFileButton = $uiHash.Window.FindName("LoadFileButton")
$uiHash.BrowseFileButton = $uiHash.Window.FindName("BrowseFileButton")
$uiHash.LoadADButton = $uiHash.Window.FindName("LoadADButton")
$uiHash.StatusTextBox = $uiHash.Window.FindName("StatusTextBox")
$uiHash.ProgressBar = $uiHash.Window.FindName("ProgressBar")
$uiHash.RunButton = $uiHash.Window.FindName("RunButton")
$uiHash.CancelButton = $uiHash.Window.FindName("CancelButton")
$uiHash.GridView = $uiHash.Window.FindName("GridView")
#endregion

#region Event Handlers

#Window Load Events
$uiHash.Window.Add_SourceInitialized({
    #Configure Options
    Write-Verbose 'Updating configuration based on options'
    Set-PoshPAIGOption 
    Write-Debug ("maxConcurrentJobs: {0}" -f $maxConcurrentJobs)
    Write-Debug ("MaxRebootJobs: {0}" -f $MaxRebootJobs)
    Write-Debug ("reportpath: {0}" -f $reportpath)
    
    #Define hashtable of settings
    $Script:SortHash = @{}
    
    #Sort event handler
    [System.Windows.RoutedEventHandler]$Global:ColumnSortHandler = {
        If ($_.OriginalSource -is [System.Windows.Controls.GridViewColumnHeader]) {
            Write-Verbose ("{0}" -f $_.Originalsource.getType().FullName)
            If ($_.OriginalSource -AND $_.OriginalSource.Role -ne 'Padding') {
                $Column = $_.Originalsource.Column.DisplayMemberBinding.Path.Path
                Write-Debug ("Sort: {0}" -f $Column)
                If ($SortHash[$Column] -eq 'Ascending') {
                    Write-Debug "Descending"
                    $SortHash[$Column]  = 'Descending'
                } Else {
                    Write-Debug "Ascending"
                    $SortHash[$Column]  = 'Ascending'
                }
                Write-Verbose ("Direction: {0}" -f $SortHash[$Column])
                $lastColumnsort = $Column
                Write-Verbose "Clearing sort descriptions"
                $uiHash.Listview.Items.SortDescriptions.clear()
                Write-Verbose ("Sorting {0} by {1}" -f $Column, $SortHash[$Column])
                $uiHash.Listview.Items.SortDescriptions.Add((New-Object System.ComponentModel.SortDescription $Column, $SortHash[$Column]))
                Write-Verbose "Refreshing View"
                $uiHash.Listview.Items.Refresh()   
            }             
        }
    }
    $uiHash.Listview.AddHandler([System.Windows.Controls.GridViewColumnHeader]::ClickEvent, $ColumnSortHandler)
    
    #Create and bind the observable collection to the GridView
    $Script:clientObservable = New-Object System.Collections.ObjectModel.ObservableCollection[object]    
    $uiHash.ListView.ItemsSource = $clientObservable
    $Global:Clients = $clientObservable | Select -Expand Computer
})    

#Window Close Events
$uiHash.Window.Add_Closed({
    #Halt job processing
    $jobCleanup.Flag = $False

    #Stop all runspaces
    $jobCleanup.PowerShell.Dispose()
    
    [gc]::Collect()
    [gc]::WaitForPendingFinalizers()    
})

#Cancel Button Event
$uiHash.CancelButton.Add_Click({
    $runspaceHash.runspacepool.Dispose()
    $uiHash.StatusTextBox.Foreground = "Black"
    $uiHash.StatusTextBox.Text = "Action cancelled" 
    [Float]$uiHash.ProgressBar.Value = 0
    $uiHash.RunButton.IsEnabled = $True
    $uiHash.StartImage.Source = "$pwd\Images\Start.jpg"
    $uiHash.CancelButton.IsEnabled = $False
    $uiHash.CancelImage.Source = "$pwd\Images\Stop_locked.jpg"    
         
})

#EntireUpdateLog Event
$uiHash.EntireLogMenu.Add_Click({
    If ($uiHash.Listview.Items.count -eq 1) {
        $selectedItem = $uiHash.Listview.SelectedItem
        [Float]$uiHash.ProgressBar.Maximum = $servers.count
        $uiHash.Listview.ItemsSource | ForEach {$_.Notes = $Null}
        $uiHash.RunButton.IsEnabled = $False
        $uiHash.StartImage.Source = "$pwd\Images\Start_locked.jpg"
        $uiHash.CancelButton.IsEnabled = $True
        $uiHash.CancelImage.Source = "$pwd\Images\Stop.jpg"         
        $uiHash.StatusTextBox.Foreground = "Black"
        $uiHash.StatusTextBox.Text = "Retrieving Windows Update log from Server..."            
        $uiHash.StartTime = (Get-Date)        
        [Float]$uiHash.ProgressBar.Value = 0

        $uiHash.Listview.Items.EditItem($selectedItem)
        $selectedItem.Notes = "Retrieving Update Log"
        $uiHash.Listview.Items.CommitEdit()
        $uiHash.Listview.Items.Refresh() 
        . .\Scripts\Get-UpdateLog.ps1
        Try {
            $log = Get-UpdateLog -Computername $selectedItem.computer 
            If ($log) {
                $log | Out-GridView -Title ("{0} Update Log" -f $selectedItem.computer)
                $selectedItem.Notes = "Completed"
            }
        } Catch {
            $selectedItem.notes = $_.Exception.Message
        }
        $uiHash.ProgressBar.value++ 
        $End = New-Timespan $uihash.StartTime (Get-Date) 
        $uiHash.StatusTextBox.Text = ("Completed in {0}" -f $end)
        $uiHash.RunButton.IsEnabled = $True
        $uiHash.StartImage.Source = "$pwd\Images\Start.jpg"
        $uiHash.CancelButton.IsEnabled = $False
        $uiHash.CancelImage.Source = "$pwd\Images\Stop_locked.jpg"
    }  
}) 

#Last100UpdateLog Event
$uiHash.Last100LogMenu.Add_Click({
    If ($uiHash.Listview.Items.count -eq 1) {
        $selectedItem = $uiHash.Listview.SelectedItem
        [Float]$uiHash.ProgressBar.Maximum = $servers.count
        $uiHash.Listview.ItemsSource | ForEach {$_.Notes = $Null}
        $uiHash.RunButton.IsEnabled = $False
        $uiHash.StartImage.Source = "$pwd\Images\Start_locked.jpg"
        $uiHash.CancelButton.IsEnabled = $True
        $uiHash.CancelImage.Source = "$pwd\Images\Stop.jpg"         
        $uiHash.StatusTextBox.Foreground = "Black"
        $uiHash.StatusTextBox.Text = "Retrieving Windows Update log from Server..."            
        $uiHash.StartTime = (Get-Date)        
        [Float]$uiHash.ProgressBar.Value = 0

        $uiHash.Listview.Items.EditItem($selectedItem)
        $selectedItem.Notes = "Retrieving Update Log"
        $uiHash.Listview.Items.CommitEdit()
        $uiHash.Listview.Items.Refresh() 
        . .\Scripts\Get-UpdateLog.ps1
        Try {
            $log = Get-UpdateLog -Last 100 -Computername $selectedItem.computer 
            If ($log) {
                $log | Out-GridView -Title ("{0} Update Log" -f $selectedItem.computer)
                $selectedItem.Notes = "Completed"
            }
        } Catch {
            $selectedItem.notes = $_.Exception.Message
        }
        $uiHash.ProgressBar.value++ 
        $End = New-Timespan $uihash.StartTime (Get-Date) 
        $uiHash.StatusTextBox.Text = ("Completed in {0}" -f $end)
        $uiHash.RunButton.IsEnabled = $True
        $uiHash.StartImage.Source = "$pwd\Images\Start.jpg"
        $uiHash.CancelButton.IsEnabled = $False
        $uiHash.CancelImage.Source = "$pwd\Images\Stop_locked.jpg"
    }       
})

#Last50UpdateLog Event
$uiHash.Last50LogMenu.Add_Click({
    If ($uiHash.Listview.Items.count -eq 1) {
        $selectedItem = $uiHash.Listview.SelectedItem
        [Float]$uiHash.ProgressBar.Maximum = $servers.count
        $uiHash.Listview.ItemsSource | ForEach {$_.Notes = $Null}
        $uiHash.RunButton.IsEnabled = $False
        $uiHash.StartImage.Source = "$pwd\Images\Start_locked.jpg"
        $uiHash.CancelButton.IsEnabled = $True
        $uiHash.CancelImage.Source = "$pwd\Images\Stop.jpg"         
        $uiHash.StatusTextBox.Foreground = "Black"
        $uiHash.StatusTextBox.Text = "Retrieving Windows Update log from Server..."            
        $uiHash.StartTime = (Get-Date)        
        [Float]$uiHash.ProgressBar.Value = 0

        $uiHash.Listview.Items.EditItem($selectedItem)
        $selectedItem.Notes = "Retrieving Update Log"
        $uiHash.Listview.Items.CommitEdit()
        $uiHash.Listview.Items.Refresh() 
        . .\Scripts\Get-UpdateLog.ps1
        Try {
            $log = Get-UpdateLog -Last 50 -Computername $selectedItem.computer 
            If ($log) {
                $log | Out-GridView -Title ("{0} Update Log" -f $selectedItem.computer)
                $selectedItem.Notes = "Completed"
            }
        } Catch {
            $selectedItem.notes = $_.Exception.Message
        }
        $uiHash.ProgressBar.value++ 
        $End = New-Timespan $uihash.StartTime (Get-Date) 
        $uiHash.StatusTextBox.Text = ("Completed in {0}" -f $end)
        $uiHash.RunButton.IsEnabled = $True
        $uiHash.StartImage.Source = "$pwd\Images\Start.jpg"
        $uiHash.CancelButton.IsEnabled = $False
        $uiHash.CancelImage.Source = "$pwd\Images\Stop_locked.jpg"
    }                  
})

#Last25UpdateLog Event
$uiHash.Last25LogMenu.Add_Click({
    If ($uiHash.Listview.Items.count -eq 1) {
        $selectedItem = $uiHash.Listview.SelectedItem
        [Float]$uiHash.ProgressBar.Maximum = $servers.count
        $uiHash.Listview.ItemsSource | ForEach {$_.Notes = $Null}
        $uiHash.RunButton.IsEnabled = $False
        $uiHash.StartImage.Source = "$pwd\Images\Start_locked.jpg"
        $uiHash.CancelButton.IsEnabled = $True
        $uiHash.CancelImage.Source = "$pwd\Images\Stop.jpg"         
        $uiHash.StatusTextBox.Foreground = "Black"
        $uiHash.StatusTextBox.Text = "Retrieving Windows Update log from Server..."            
        $uiHash.StartTime = (Get-Date)        
        [Float]$uiHash.ProgressBar.Value = 0

        $uiHash.Listview.Items.EditItem($selectedItem)
        $selectedItem.Notes = "Retrieving Update Log"
        $uiHash.Listview.Items.CommitEdit()
        $uiHash.Listview.Items.Refresh() 
        . .\Scripts\Get-UpdateLog.ps1
        Try {
            $log = Get-UpdateLog -Last 25 -Computername $selectedItem.computer 
            If ($log) {
                $log | Out-GridView -Title ("{0} Update Log" -f $selectedItem.computer)
                $selectedItem.Notes = "Completed"
            }
        } Catch {
            $selectedItem.notes = $_.Exception.Message
        }
        $uiHash.ProgressBar.value++ 
        $End = New-Timespan $uihash.StartTime (Get-Date) 
        $uiHash.StatusTextBox.Text = ("Completed in {0}" -f $end)
        $uiHash.RunButton.IsEnabled = $True
        $uiHash.StartImage.Source = "$pwd\Images\Start.jpg"
        $uiHash.CancelButton.IsEnabled = $False
        $uiHash.CancelImage.Source = "$pwd\Images\Stop_locked.jpg"             
    }    
})

#Offline server removal
$uiHash.OfflineHostsMenu.Add_Click({
    Write-Verbose "Removing any server that is shown as offline"
    $Offline = @($uiHash.Listview.Items | Where {$_.Notes -eq "Offline"})
    $Offline | ForEach {
        Write-Verbose ("Removing {0}" -f $_.Computer)
        $clientObservable.Remove($_)
        }
    $uiHash.ProgressBar.Maximum = $uiHash.Listview.ItemsSource.count
})

#ResetAuthorization Event
$uiHash.ResetAuthorizationMenu.Add_Click({
    If ($uiHash.Listview.Items.count -gt 0) {
        $Servers = $uiHash.Listview.SelectedItems | Select -ExpandProperty Computer
        [Float]$uiHash.ProgressBar.Maximum = $servers.count
        $uiHash.Listview.ItemsSource | ForEach {$_.Notes = $Null}
        $uiHash.RunButton.IsEnabled = $False
        $uiHash.StartImage.Source = "$pwd\Images\Start_locked.jpg"
        $uiHash.CancelButton.IsEnabled = $True
        $uiHash.CancelImage.Source = "$pwd\Images\Stop.jpg"
        $uiHash.StatusTextBox.Foreground = "Black"
        $uiHash.StatusTextBox.Text = "Forcing Reset Authorization on Servers"           
        $uiHash.StartTime = (Get-Date)        
        [Float]$uiHash.ProgressBar.Value = 0
        $scriptBlock = {
            Param (
                $Computer,
                $uiHash,
                $Path
            )               
            $uiHash.ListView.Dispatcher.Invoke("Normal",[action]{ 
                $uiHash.Listview.Items.EditItem($Computer)
                $computer.Notes = "Reset Authorization on Update Client"
                $uiHash.Listview.Items.CommitEdit()
                $uiHash.Listview.Items.Refresh() 
            })                
            Set-Location $Path
            $wmi = @{
                Computername = $computer.computer
                Class = "Win32_Process"
                Name = "Create"
                ErrorAction = "Stop"
                ArgumentList = "wuauclt /resetauthorization"
            }
            Try {
                If ((Invoke-WmiMethod @wmi).ReturnValue -eq 0) {
                    $result = $True
                } Else {
                    $result = $False
                }
            } Catch {
                $result = $False
                $returnMessage = $_.Exception.Message
            }
            $uiHash.ListView.Dispatcher.Invoke("Background",[action]{                    
                $uiHash.Listview.Items.EditItem($Computer)
                If ($result) {
                    $Computer.Notes = "Completed"
                } Else {
                    $computer.notes = ("Issue Occurred: {0}" -f $returnMessage)
                } 
                $uiHash.Listview.Items.CommitEdit()
                $uiHash.Listview.Items.Refresh()
                $uiHash.ProgressBar.value++  
                    
                #Check to see if find job
                If ($uiHash.ProgressBar.value -eq $uiHash.ProgressBar.Maximum) { 
                    $End = New-Timespan $uihash.StartTime (Get-Date)                                             
                    $uiHash.StatusTextBox.Text = ("Completed in {0}" -f $end)
                    $uiHash.RunButton.IsEnabled = $True
                    $uiHash.StartImage.Source = "$pwd\Images\Start.jpg"
                    $uiHash.CancelButton.IsEnabled = $False
                    $uiHash.CancelImage.Source = "$pwd\Images\Stop_locked.jpg"                    
                }
            })  
                
        }

        Write-Verbose ("Creating runspace pool and session states")
        $sessionstate = [system.management.automation.runspaces.initialsessionstate]::CreateDefault()
        $runspaceHash.runspacepool = [runspacefactory]::CreateRunspacePool(1, $maxConcurrentJobs, $sessionstate, $Host)
        $runspaceHash.runspacepool.Open()   

        ForEach ($Computer in $selectedItems) {
            $uiHash.Listview.Items.EditItem($Computer)
            $computer.Notes = "Pending ResetAuthorization"
            $uiHash.Listview.Items.CommitEdit()
            $uiHash.Listview.Items.Refresh() 
            #Create the powershell instance and supply the scriptblock with the other parameters 
            $powershell = [powershell]::Create().AddScript($ScriptBlock).AddArgument($computer).AddArgument($uiHash).AddArgument($Path)
           
            #Add the runspace into the powershell instance
            $powershell.RunspacePool = $runspaceHash.runspacepool
           
            #Create a temporary collection for each runspace
            $temp = "" | Select-Object PowerShell,Runspace,Computer
            $Temp.Computer = $Computer.computer
            $temp.PowerShell = $powershell
           
            #Save the handle output when calling BeginInvoke() that will be used later to end the runspace
            $temp.Runspace = $powershell.BeginInvoke()
            Write-Verbose ("Adding {0} collection" -f $temp.Computer)
            $jobs.Add($temp) | Out-Null
        } 
    
    }    
})  
    
#DetectNow Event
$uiHash.ResetAuthorizationMenu.Add_Click({
    If ($uiHash.Listview.Items.count -gt 0) {
        $Servers = $uiHash.Listview.SelectedItems | Select -ExpandProperty Computer
        [Float]$uiHash.ProgressBar.Maximum = $servers.count
        $uiHash.Listview.ItemsSource | ForEach {$_.Notes = $Null}
        $uiHash.RunButton.IsEnabled = $False
        $uiHash.StartImage.Source = "$pwd\Images\Start_locked.jpg"
        $uiHash.CancelButton.IsEnabled = $True
        $uiHash.CancelImage.Source = "$pwd\Images\Stop.jpg"
        $uiHash.StatusTextBox.Foreground = "Black"
        $uiHash.StatusTextBox.Text = "Forcing Re-Detection of Update Client on Servers"          
        $uiHash.StartTime = (Get-Date)        
        [Float]$uiHash.ProgressBar.Value = 0
        $scriptBlock = {
            Param (
                $Computer,
                $uiHash,
                $Path
            )               
            $uiHash.ListView.Dispatcher.Invoke("Normal",[action]{ 
                $uiHash.Listview.Items.EditItem($Computer)
                $computer.Notes = "Re-Detect on Update Client"
                $uiHash.Listview.Items.CommitEdit()
                $uiHash.Listview.Items.Refresh() 
            })                
            Set-Location $Path
            $wmi = @{
                Computername = $computer.computer
                Class = "Win32_Process"
                Name = "Create"
                ErrorAction = "Stop"
                ArgumentList = "wuauclt /detectnow"
            }
            Try {
                If ((Invoke-WmiMethod @wmi).ReturnValue -eq 0) {
                    $result = $True
                } Else {
                    $result = $False
                }
            } Catch {
                $result = $False
                $returnMessage = $_.Exception.Message
            }
            $uiHash.ListView.Dispatcher.Invoke("Background",[action]{                    
                $uiHash.Listview.Items.EditItem($Computer)
                If ($result) {
                    $Computer.Notes = "Completed"
                } Else {
                    $computer.notes = ("Issue Occurred: {0}" -f $returnMessage)
                } 
                $uiHash.Listview.Items.CommitEdit()
                $uiHash.Listview.Items.Refresh()
                $uiHash.ProgressBar.value++  
                    
                #Check to see if find job
                If ($uiHash.ProgressBar.value -eq $uiHash.ProgressBar.Maximum) { 
                    $End = New-Timespan $uihash.StartTime (Get-Date)                                             
                    $uiHash.StatusTextBox.Text = ("Completed in {0}" -f $end)
                    $uiHash.RunButton.IsEnabled = $True
                    $uiHash.StartImage.Source = "$pwd\Images\Start.jpg"
                    $uiHash.CancelButton.IsEnabled = $False
                    $uiHash.CancelImage.Source = "$pwd\Images\Stop_locked.jpg"                    
                }
            })  
                
        }

        Write-Verbose ("Creating runspace pool and session states")
        $sessionstate = [system.management.automation.runspaces.initialsessionstate]::CreateDefault()
        $runspaceHash.runspacepool = [runspacefactory]::CreateRunspacePool(1, $maxConcurrentJobs, $sessionstate, $Host)
        $runspaceHash.runspacepool.Open()   

        ForEach ($Computer in $selectedItems) {
            $uiHash.Listview.Items.EditItem($Computer)
            $computer.Notes = "Pending DetectNow"
            $uiHash.Listview.Items.CommitEdit()
            $uiHash.Listview.Items.Refresh() 
            #Create the powershell instance and supply the scriptblock with the other parameters 
            $powershell = [powershell]::Create().AddScript($ScriptBlock).AddArgument($computer).AddArgument($uiHash).AddArgument($Path)
           
            #Add the runspace into the powershell instance
            $powershell.RunspacePool = $runspaceHash.runspacepool
           
            #Create a temporary collection for each runspace
            $temp = "" | Select-Object PowerShell,Runspace,Computer
            $Temp.Computer = $Computer.computer
            $temp.PowerShell = $powershell
           
            #Save the handle output when calling BeginInvoke() that will be used later to end the runspace
            $temp.Runspace = $powershell.BeginInvoke()
            Write-Verbose ("Adding {0} collection" -f $temp.Computer)
            $jobs.Add($temp) | Out-Null
        } 
    
    }    
})        

#Rightclick Event
$uiHash.Listview.Add_MouseRightButtonUp({
    Write-Debug "$($This.SelectedItem.Row.Computer)"
    If ($uiHash.Listview.SelectedItems.count -eq 0) {
        $uiHash.RemoveServerMenu.IsEnabled = $False
        $uiHash.InstalledUpdatesMenu.IsEnabled = $False
        $uiHash.WindowsUpdateLogMenu.IsEnabled = $False
        $uiHash.WindowsUpdateServiceMenu.IsEnabled = $False
        $uiHash.WUAUCLTMenu.IsEnabled = $False
        } ElseIf ($uiHash.Listview.SelectedItems.count -eq 1) {
        $uiHash.RemoveServerMenu.IsEnabled = $True
        $uiHash.InstalledUpdatesMenu.IsEnabled = $True
        $uiHash.WindowsUpdateLogMenu.IsEnabled = $True
        $uiHash.WindowsUpdateServiceMenu.IsEnabled = $True
        $uiHash.WUAUCLTMenu.IsEnabled = $True      
        } Else {
        $uiHash.RemoveServerMenu.IsEnabled = $True
        $uiHash.InstalledUpdatesMenu.IsEnabled = $True
        $uiHash.WindowsUpdateLogMenu.IsEnabled = $False
        $uiHash.WUAUCLTMenu.IsEnabled = $True     
    }    
})

#ListView drop file Event
$uiHash.Listview.add_Drop({
    $content = Get-Content $_.Data.GetFileDropList()
    $content | ForEach {
        $clientObservable.Add((
            New-Object PSObject -Property @{
                Computer = $_
                Audited = 0 -as [int]
                Installed = 0 -as [int]
                InstallErrors = 0 -as [int]
                Services = 0 -as [int]
                Notes = $Null
            }
        ))      
    }
    Show-DebugState
})

#FindFile Button
$uiHash.BrowseFileButton.Add_Click({
    $File = Open-FileDialog
    If (-Not ([system.string]::IsNullOrEmpty($File))) {
        Get-Content $File | Where {$_ -ne ""} | ForEach {
            $clientObservable.Add((
                New-Object PSObject -Property @{
                    Computer = $_
                    Audited = 0 -as [int]
                    Installed = 0 -as [int]
                    InstallErrors = 0 -as [int]
                    Services = 0 -as [int]
                    Notes = $Null
                }
            ))       
        }
        $uiHash.StatusTextBox.Foreground = "Black"
        $uiHash.StatusTextBox.Text = "Waiting for action..."
        Show-DebugState     
    }        
})

#LoadADButton Events    
$uiHash.LoadADButton.Add_Click({
    $domain = Open-DomainDialog
    $uiHash.StatusTextBox.Foreground = "Black"
    $uiHash.StatusTextBox.Text = "Querying Active Directory for Computers..."
    $Searcher = [adsisearcher]""  
    $Searcher.SearchRoot= [adsi]"LDAP://$domain"
    $Searcher.Filter = ("(&(objectCategory=computer)(OperatingSystem=*server*))")
    $Searcher.PropertiesToLoad.Add('name') | Out-Null
    Write-Verbose "Checking for exempt list"
    If (Test-Path Exempt.txt) {
        Write-Verbose "Collecting systems from exempt list"
        [string[]]$exempt = Get-Content Exempt.txt
    }
    $Results = $Searcher.FindAll()
    foreach ($result in $Results) {
        [string]$computer = $result.Properties.name
        If ($Exempt -notcontains $computer -AND $clients -notcontains $computer) {
            $clientObservable.Add((
                New-Object PSObject -Property @{
                    Computer = $computer
                    Audited = 0 -as [int]
                    Installed = 0 -as [int]
                    InstallErrors = 0 -as [int]
                    Services = 0 -as [int]
                    Notes = $Null
                }
            ))     
        } Else {
            Write-Verbose "Excluding $computer"
        }
    }
    $uiHash.ProgressBar.Maximum = $uiHash.Listview.ItemsSource.count   
    $Global:clients = $clientObservable | Select -Expand Computer
    Show-DebugState                      
})

#RunButton Events    
$uiHash.RunButton.add_Click({
    Start-RunJob      
})

#region Client 31.39.1.252 Service Action
#Stop Service
$uiHash.WUStopServiceMenu.Add_Click({
    If ($uiHash.Listview.Items.count -gt 0) {
        $Servers = $uiHash.Listview.SelectedItems | Select -ExpandProperty Computer
        [Float]$uiHash.ProgressBar.Maximum = $servers.count
        $uiHash.Listview.ItemsSource | ForEach {$_.Notes = $Null}
        $uiHash.RunButton.IsEnabled = $False
        $uiHash.StartImage.Source = "$pwd\Images\Start_locked.jpg"
        $uiHash.CancelButton.IsEnabled = $True
        $uiHash.CancelImage.Source = "$pwd\Images\Stop.jpg"
        $uiHash.StatusTextBox.Foreground = "Black"
        $uiHash.StatusTextBox.Text = "Stopping 31.39.1.252 Client service on selected servers"            
        $uiHash.StartTime = (Get-Date)        
        [Float]$uiHash.ProgressBar.Value = 0
        $scriptBlock = {
            Param (
                $Computer,
                $uiHash,
                $Path
            )               
            $uiHash.ListView.Dispatcher.Invoke("Normal",[action]{ 
                $uiHash.Listview.Items.EditItem($Computer)
                $computer.Notes = "Stopping Update Client Service"
                $uiHash.Listview.Items.CommitEdit()
                $uiHash.Listview.Items.Refresh() 
            })                
            Set-Location $Path
            Try {
                $updateClient = Get-Service -ComputerName $computer.computer -Name wuauserv -ErrorAction Stop
                Stop-Service -inputObject $updateClient -ErrorAction Stop
                $result = $True
            } Catch {
                $updateClient = $_.Exception.Message
            }
            $uiHash.ListView.Dispatcher.Invoke("Background",[action]{                    
                $uiHash.Listview.Items.EditItem($Computer)
                If ($result) {
                    $Computer.Notes = "Service Stopped"
                } Else {
                    $computer.notes = ("Issue Occurred: {0}" -f $updateClient)
                } 
                $uiHash.Listview.Items.CommitEdit()
                $uiHash.Listview.Items.Refresh()
            })
            $uiHash.ProgressBar.Dispatcher.Invoke("Background",[action]{   
                $uiHash.ProgressBar.value++  
            })
            $uiHash.Window.Dispatcher.Invoke("Background",[action]{                       
                #Check to see if find job
                If ($uiHash.ProgressBar.value -eq $uiHash.ProgressBar.Maximum) { 
                    $End = New-Timespan $uihash.StartTime (Get-Date)                                             
                    $uiHash.StatusTextBox.Text = ("Completed in {0}" -f $end)
                    $uiHash.RunButton.IsEnabled = $True
                    $uiHash.StartImage.Source = "$pwd\Images\Start.jpg"
                    $uiHash.CancelButton.IsEnabled = $False
                    $uiHash.CancelImage.Source = "$pwd\Images\Stop_locked.jpg"                    
                }
            })  
                
        }

        Write-Verbose ("Creating runspace pool and session states")
        $sessionstate = [system.management.automation.runspaces.initialsessionstate]::CreateDefault()
        $runspaceHash.runspacepool = [runspacefactory]::CreateRunspacePool(1, $maxConcurrentJobs, $sessionstate, $Host)
        $runspaceHash.runspacepool.Open()   

        ForEach ($Computer in $selectedItems) {
            $uiHash.Listview.Items.EditItem($Computer)
            $computer.Notes = "Pending Stop Service"
            $uiHash.Listview.Items.CommitEdit()
            $uiHash.Listview.Items.Refresh() 
            #Create the powershell instance and supply the scriptblock with the other parameters 
            $powershell = [powershell]::Create().AddScript($ScriptBlock).AddArgument($computer).AddArgument($uiHash).AddArgument($Path)
           
            #Add the runspace into the powershell instance
            $powershell.RunspacePool = $runspaceHash.runspacepool
           
            #Create a temporary collection for each runspace
            $temp = "" | Select-Object PowerShell,Runspace,Computer
            $Temp.Computer = $Computer.computer
            $temp.PowerShell = $powershell
           
            #Save the handle output when calling BeginInvoke() that will be used later to end the runspace
            $temp.Runspace = $powershell.BeginInvoke()
            Write-Verbose ("Adding {0} collection" -f $temp.Computer)
            $jobs.Add($temp) | Out-Null
        }     
    }    
})

#Start Service
$uiHash.WUStartServiceMenu.Add_Click({
    If ($uiHash.Listview.Items.count -gt 0) {
        $Servers = $uiHash.Listview.SelectedItems | Select -ExpandProperty Computer
        [Float]$uiHash.ProgressBar.Maximum = $servers.count
        $uiHash.Listview.ItemsSource | ForEach {$_.Notes = $Null}
        $uiHash.RunButton.IsEnabled = $False
        $uiHash.StartImage.Source = "$pwd\Images\Start_locked.jpg"
        $uiHash.CancelButton.IsEnabled = $True
        $uiHash.CancelImage.Source = "$pwd\Images\Stop.jpg"
        $uiHash.StatusTextBox.Foreground = "Black"
        $uiHash.StatusTextBox.Text = "Starting 31.39.1.252 Client service on selected servers"            
        $uiHash.StartTime = (Get-Date)        
        [Float]$uiHash.ProgressBar.Value = 0
        $scriptBlock = {
            Param (
                $Computer,
                $uiHash,
                $Path
            )               
            $uiHash.ListView.Dispatcher.Invoke("Normal",[action]{ 
                $uiHash.Listview.Items.EditItem($Computer)
                $computer.Notes = "Starting Update Client Service"
                $uiHash.Listview.Items.CommitEdit()
                $uiHash.Listview.Items.Refresh() 
            })                
            Set-Location $Path
            Try {
                $updateClient = Get-Service -ComputerName $computer.computer -Name wuauserv -ErrorAction Stop
                Start-Service -inputObject $updateClient -ErrorAction Stop
                $result = $True
            } Catch {
                $updateClient = $_.Exception.Message
            }
            $uiHash.ListView.Dispatcher.Invoke("Background",[action]{                    
                $uiHash.Listview.Items.EditItem($Computer)
                If ($result) {
                    $Computer.Notes = "Service Started"
                } Else {
                    $computer.notes = ("Issue Occurred: {0}" -f $updateClient)
                } 
                $uiHash.Listview.Items.CommitEdit()
                $uiHash.Listview.Items.Refresh()
            })
            $uiHash.ProgressBar.Dispatcher.Invoke("Background",[action]{   
                $uiHash.ProgressBar.value++  
            })
            $uiHash.Window.Dispatcher.Invoke("Background",[action]{           
                #Check to see if find job
                If ($uiHash.ProgressBar.value -eq $uiHash.ProgressBar.Maximum) { 
                    $End = New-Timespan $uihash.StartTime (Get-Date)                                             
                    $uiHash.StatusTextBox.Text = ("Completed in {0}" -f $end)
                    $uiHash.RunButton.IsEnabled = $True
                    $uiHash.StartImage.Source = "$pwd\Images\Start.jpg"
                    $uiHash.CancelButton.IsEnabled = $False
                    $uiHash.CancelImage.Source = "$pwd\Images\Stop_locked.jpg"                    
                }
            })  
                
        }

        Write-Verbose ("Creating runspace pool and session states")
        $sessionstate = [system.management.automation.runspaces.initialsessionstate]::CreateDefault()
        $runspaceHash.runspacepool = [runspacefactory]::CreateRunspacePool(1, $maxConcurrentJobs, $sessionstate, $Host)
        $runspaceHash.runspacepool.Open()   

        ForEach ($Computer in $selectedItems) {
            $uiHash.Listview.Items.EditItem($Computer)
            $computer.Notes = "Pending Start Service"
            $uiHash.Listview.Items.CommitEdit()
            $uiHash.Listview.Items.Refresh()
            #Create the powershell instance and supply the scriptblock with the other parameters 
            $powershell = [powershell]::Create().AddScript($ScriptBlock).AddArgument($computer).AddArgument($uiHash).AddArgument($Path)
           
            #Add the runspace into the powershell instance
            $powershell.RunspacePool = $runspaceHash.runspacepool
           
            #Create a temporary collection for each runspace
            $temp = "" | Select-Object PowerShell,Runspace,Computer
            $Temp.Computer = $Computer.computer
            $temp.PowerShell = $powershell
           
            #Save the handle output when calling BeginInvoke() that will be used later to end the runspace
            $temp.Runspace = $powershell.BeginInvoke()
            Write-Verbose ("Adding {0} collection" -f $temp.Computer)
            $jobs.Add($temp) | Out-Null
        } 
    
    }    
})

#Restart Service
$uiHash.WURestartServiceMenu.Add_Click({
    If ($uiHash.Listview.Items.count -gt 0) {
        $Servers = $uiHash.Listview.SelectedItems | Select -ExpandProperty Computer
        [Float]$uiHash.ProgressBar.Maximum = $servers.count
        $uiHash.Listview.ItemsSource | ForEach {$_.Notes = $Null}
        $uiHash.RunButton.IsEnabled = $False
        $uiHash.StartImage.Source = "$pwd\Images\Start_locked.jpg"
        $uiHash.CancelButton.IsEnabled = $True
        $uiHash.CancelImage.Source = "$pwd\Images\Stop.jpg"
        $uiHash.StatusTextBox.Foreground = "Black"
        $uiHash.StatusTextBox.Text = "Restarting 31.39.1.252 Client service on selected servers"            
        $uiHash.StartTime = (Get-Date)        
        [Float]$uiHash.ProgressBar.Value = 0
        $scriptBlock = {
            Param (
                $Computer,
                $uiHash,
                $Path
            )               
            $uiHash.ListView.Dispatcher.Invoke("Normal",[action]{ 
                $uiHash.Listview.Items.EditItem($Computer)
                $computer.Notes = "Restarting Update Client Service"
                $uiHash.Listview.Items.CommitEdit()
                $uiHash.Listview.Items.Refresh() 
            })                
            Set-Location $Path
            Try {
                $updateClient = Get-Service -ComputerName $computer.computer -Name wuauserv -ErrorAction Stop
                Restart-Service -inputObject $updateClient -ErrorAction Stop
                $result = $True
            } Catch {
                $updateClient = $_.Exception.Message
            }
            $uiHash.ListView.Dispatcher.Invoke("Background",[action]{                    
                $uiHash.Listview.Items.EditItem($Computer)
                If ($result) {
                    $Computer.Notes = "Service Restarted"
                } Else {
                    $computer.notes = ("Issue Occurred: {0}" -f $updateClient)
                } 
                $uiHash.Listview.Items.CommitEdit()
                $uiHash.Listview.Items.Refresh()
            })
            $uiHash.ProgressBar.Dispatcher.Invoke("Background",[action]{   
                $uiHash.ProgressBar.value++  
            })
            $uiHash.Window.Dispatcher.Invoke("Background",[action]{           
                #Check to see if find job
                If ($uiHash.ProgressBar.value -eq $uiHash.ProgressBar.Maximum) { 
                    $End = New-Timespan $uihash.StartTime (Get-Date)                                             
                    $uiHash.StatusTextBox.Text = ("Completed in {0}" -f $end)
                    $uiHash.RunButton.IsEnabled = $True
                    $uiHash.StartImage.Source = "$pwd\Images\Start.jpg"
                    $uiHash.CancelButton.IsEnabled = $False
                    $uiHash.CancelImage.Source = "$pwd\Images\Stop_locked.jpg"                    
                }
            })  
                
        }

        Write-Verbose ("Creating runspace pool and session states")
        $sessionstate = [system.management.automation.runspaces.initialsessionstate]::CreateDefault()
        $runspaceHash.runspacepool = [runspacefactory]::CreateRunspacePool(1, $maxConcurrentJobs, $sessionstate, $Host)
        $runspaceHash.runspacepool.Open()   

        ForEach ($Computer in $selectedItems) {
            $uiHash.Listview.Items.EditItem($Computer)
            $computer.Notes = "Pending Restart Service"
            $uiHash.Listview.Items.CommitEdit()
            $uiHash.Listview.Items.Refresh()
            #Create the powershell instance and supply the scriptblock with the other parameters 
            $powershell = [powershell]::Create().AddScript($ScriptBlock).AddArgument($computer).AddArgument($uiHash).AddArgument($Path)
           
            #Add the runspace into the powershell instance
            $powershell.RunspacePool = $runspaceHash.runspacepool
           
            #Create a temporary collection for each runspace
            $temp = "" | Select-Object PowerShell,Runspace,Computer
            $Temp.Computer = $Computer.computer
            $temp.PowerShell = $powershell
           
            #Save the handle output when calling BeginInvoke() that will be used later to end the runspace
            $temp.Runspace = $powershell.BeginInvoke()
            Write-Verbose ("Adding {0} collection" -f $temp.Computer)
            $jobs.Add($temp) | Out-Null
        } 
    
    }    
})
#endregion

#View Installed Update Event
$uiHash.GUIInstalledUpdatesMenu.Add_Click({
    If ($uiHash.Listview.Items.count -gt 0) {
        $selectedItems = $uiHash.Listview.SelectedItems
        [Float]$uiHash.ProgressBar.Maximum = $servers.count
        $uiHash.Listview.ItemsSource | ForEach {$_.Notes = $Null}
        $uiHash.RunButton.IsEnabled = $False
        $uiHash.StartImage.Source = "$pwd\Images\Start_locked.jpg"
        $uiHash.CancelButton.IsEnabled = $True
        $uiHash.CancelImage.Source = "$pwd\Images\Stop.jpg"        
        $uiHash.StatusTextBox.Foreground = "Black"
        $uiHash.StatusTextBox.Text = "Gathering all installed patches on Servers"            
        $uiHash.StartTime = (Get-Date)        
        [Float]$uiHash.ProgressBar.Value = 0             

        $scriptBlock = {
            Param (
                $Computer,
                $uiHash,
                $Path,
                $installedUpdates
            )               
            $uiHash.ListView.Dispatcher.Invoke("Normal",[action]{ 
                $uiHash.Listview.Items.EditItem($Computer)
                $computer.Notes = "Querying Installed Updates"
                $uiHash.Listview.Items.CommitEdit()
                $uiHash.Listview.Items.Refresh() 
            })                
            Set-Location $Path
            Try {
                $updates = Get-HotFix -ComputerName $computer.computer -ErrorAction Stop | Where {$_.Description -ne ""}
                If ($updates) {
                    $installedUpdates.AddRange($updates) | Out-Null
                }
            } Catch {
                $result = $_.exception.Message
            }
            $uiHash.ListView.Dispatcher.Invoke("Background",[action]{                    
                $uiHash.Listview.Items.EditItem($Computer)
                If ($result) {
                    $computer.Notes = $result
                } Else {
                    $computer.Notes = "Completed"
                }
                $uiHash.Listview.Items.CommitEdit()
                $uiHash.Listview.Items.Refresh()
            })
            $uiHash.ProgressBar.Dispatcher.Invoke("Background",[action]{   
                $uiHash.ProgressBar.value++  
            })
            $uiHash.Window.Dispatcher.Invoke("Background",[action]{           
                #Check to see if find job
                If ($uiHash.ProgressBar.value -eq $uiHash.ProgressBar.Maximum) { 
                    $End = New-Timespan $uihash.StartTime (Get-Date)                                             
                    $uiHash.StatusTextBox.Text = ("Completed in {0}" -f $end)
                    $uiHash.RunButton.IsEnabled = $True
                    $uiHash.StartImage.Source = "$pwd\Images\Start.jpg"
                    $uiHash.CancelButton.IsEnabled = $False
                    $uiHash.CancelImage.Source = "$pwd\Images\Stop_locked.jpg"                 
                }
            })  
                
        }
        Write-Verbose ("Creating runspace pool and session states")
        $sessionstate = [system.management.automation.runspaces.initialsessionstate]::CreateDefault()
        $runspaceHash.runspacepool = [runspacefactory]::CreateRunspacePool(1, $maxConcurrentJobs, $sessionstate, $Host)
        $runspaceHash.runspacepool.Open()   

        ForEach ($Computer in $selectedItems) {
            #Create the powershell instance and supply the scriptblock with the other parameters 
            $powershell = [powershell]::Create().AddScript($ScriptBlock).AddArgument($computer).AddArgument($uiHash).AddArgument($Path).AddArgument($installedUpdates)
           
            #Add the runspace into the powershell instance
            $powershell.RunspacePool = $runspaceHash.runspacepool
           
            #Create a temporary collection for each runspace
            $temp = "" | Select-Object PowerShell,Runspace,Computer
            $Temp.Computer = $Computer.computer
            $temp.PowerShell = $powershell
           
            #Save the handle output when calling BeginInvoke() that will be used later to end the runspace
            $temp.Runspace = $powershell.BeginInvoke()
            Write-Verbose ("Adding {0} collection" -f $temp.Computer)
            $jobs.Add($temp) | Out-Null                
        }
    }
})

#ClearAuditReportMenu Events    
$uiHash.ClearAuditReportMenu.Add_Click({
    $updateAudit.Clear()
    $uiHash.StatusTextBox.Foreground = "Black"
    $uiHash.StatusTextBox.Text = "Audit Report Cleared!"  
})

#ClearInstallReportMenu Events    
$uiHash.ClearInstallReportMenu.Add_Click({
    Remove-Variable InstallPatchReport -scope Global -force -ea 'silentlycontinue'
    $uiHash.StatusTextBox.Foreground = "Black"
    $uiHash.StatusTextBox.Text = "Install Report Cleared!"  
})

#ClearInstalledUpdateMenu
$uiHash.ClearInstalledUpdateMenu.Add_Click({
    Remove-Variable InstalledPatches -scope Global -force -ea 'silentlycontinue'
    $uiHash.StatusTextBox.Foreground = "Black"
    $uiHash.StatusTextBox.Text = "Installed Updates Report Cleared!"    
})
    
#ClearServerListMenu Events    
$uiHash.ClearServerListMenu.Add_Click({
    $clientObservable.Clear()
    $uiHash.StatusTextBox.Foreground = "Black"
    $uiHash.StatusTextBox.Text = "Server List Cleared!"  
})    

#AboutMenu Event
$uiHash.AboutMenu.Add_Click({
    Open-PoshPAIGAbout
})

#Options Menu
$uiHash.OptionMenu.Add_Click({
    #Launch options window
    Write-Verbose "Launching Options Menu"
    .\Options.ps1
    #Process Updates Options
    Set-PoshPAIGOption    
})

#Select All
$uiHash.SelectAllMenu.Add_Click({
    $uiHash.Listview.SelectAll()
})

#HelpFileMenu Event
$uiHash.HelpFileMenu.Add_Click({
    Open-PoshPAIGHelp
})

#KeyDown Event
$uiHash.Window.Add_KeyDown({ 
    $key = $_.Key  
    If ([System.Windows.Input.Keyboard]::IsKeyDown("RightCtrl") -OR [System.Windows.Input.Keyboard]::IsKeyDown("LeftCtrl")) {
        Switch ($Key) {
        "E" {$This.Close()}
        "A" {$uiHash.Listview.SelectAll()}
        "O" {
            .\Options.ps1
            #Process Updates Options
            Set-PoshPAIGOption
        }
        "S" {Add-Server}
        "D" {Remove-Server}
        Default {$Null}
        }
    } ElseIf ([System.Windows.Input.Keyboard]::IsKeyDown("LeftShift") -OR [System.Windows.Input.Keyboard]::IsKeyDown("RightShift")) {
        Switch ($Key) {
            "RETURN" {Write-Host "Hit Shift+Return"}
        }
    }   

})

#Key Up Event
$uiHash.Window.Add_KeyUp({
    $Global:Test = $_
    Write-Debug ("Key Pressed: {0}" -f $_.Key)
    Switch ($_.Key) {
        "F1" {Open-PoshPAIGHelp}
        "F5" {Start-RunJob}
        "F8" {Start-Report}
        Default {$Null}
    }

})

#AddServer Menu
$uiHash.AddServerMenu.Add_Click({
    Add-Server   
})

#RemoveServer Menu
$uiHash.RemoveServerMenu.Add_Click({
    Remove-Server 
})  

#Run Menu
$uiHash.RunMenu.Add_Click({
    Start-RunJob
})      
      
#Report Menu
$uiHash.GenerateReportMenu.Add_Click({
    Start-Report
})       
      
#Exit Menu
$uiHash.ExitMenu.Add_Click({
    $uiHash.Window.Close()
})

#ClearAll Menu
$uiHash.ClearAllMenu.Add_Click({
    $clientObservable.Clear()
    $content = $Null
    [Float]$uiHash.ProgressBar.value = 0
    $uiHash.StatusTextBox.Foreground = "Black"
    $Global:updateAudit.Clear()
    $uiHash.StatusTextBox.Text = "Waiting for action..."    
})

#Clear Server List notes
$uiHash.ClearServerListNotesMenu.Add_Click({
    If ($uiHash.Listview.Items.count -gt 0) {
        $uiHash.Listview.ItemsSource | ForEach {$_.Notes = $Null}
        }
})

#Save Server List
$uiHash.ServerListReportMenu.Add_Click({
    If ($uiHash.Listview.Items.count -gt 0) {
        $uiHash.StatusTextBox.Foreground = "Black"
        $savedreport = Join-Path (Join-Path $home Desktop) "serverlist.csv"
        $uiHash.Listview.ItemsSource | Export-Csv -NoTypeInformation $savedreport
        $uiHash.StatusTextBox.Text = "Report saved to $savedreport"        
    } Else {
        $uiHash.StatusTextBox.Foreground = "Red"
        $uiHash.StatusTextBox.Text = "No report to create!"         
    }         
})
     
#HostListMenu
$uiHash.HostListMenu.Add_Click({
    If ($uiHash.Listview.Items.count -gt 0) { 
        $uiHash.StatusTextBox.Foreground = "Black"
        $savedreport = Join-Path $reportpath "hosts.txt"
        $uiHash.Listview.DataContext | Select -Expand Computer | Out-File $savedreport
        $uiHash.StatusTextBox.Text = "Report saved to $savedreport"
        } Else {
        $uiHash.StatusTextBox.Foreground = "Red"
        $uiHash.StatusTextBox.Text = "No report to create!"         
    }         
})     

#Report Generation
$uiHash.GenerateReportButton.Add_Click({
    Start-Report
})

#Clear Error log
$uiHash.ClearErrorMenu.Add_Click({
    Write-Verbose "Clearing error log"
    $Error.Clear()
})

#View Error Event
$uiHash.ViewErrorMenu.Add_Click({
    Get-Error | Out-GridView
})

#ResetServerListData Event
$uiHash.ResetDataMenu.Add_Click({
    Write-Verbose "Resetting Server List data"
    $uiHash.Listview.ItemsSource | ForEach {$_.Notes = $Null;$_.Audited = 0;$_.Installed = 0;$_.InstallErrors = 0;$_.Services = 0}
})
#endregion        

#Start the GUI
$uiHash.Window.ShowDialog() | Out-Null