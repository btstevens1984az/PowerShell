# Purpose: Get-ComputerHealthHTMLReport — McAfee ePolicy Orchestrator reporting.
Function Get-ComputerHealthHTMLReport {

#Global Variables#
$reportdir = "C:\Temp\Reports"
$reportdate = Get-Date -Format M-d-yyyy
$report = "Network Health Report for $domainnm-$reportdate.html"
$eventreport = "Event Log Report for $domainnm-$reportdate.html"
$domainreport = "Domain Health Report for $domainnm-$reportdate.html"
$Servers = @("7.140.238.34", "198.149.86.32", "23.224.109.49")  # Configure for your environment,"LocalHost"

$mailserver = "smtp.example.com"

$ErrorActionPreference = "SilentlyContinue"
#Define Global Table Header#
$header = @"
<style>
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #3085e0;color: #ffff00}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
h1 {color: #000000; margin:10px 0px 0px 0px}
h2 {color: #1f66be; margin:10px 0px 0px 0px}
h3 {color: #028bff; margin:10px 0px 0px 0px}
body {background-color: #bcbcbc}
</style>
<title>Network Health Report for $domainnm</title>
"@

#Define ScriptBlock for remote execution#

$eventblock =
{
    Import-Module ServerManager
    Import-Module BestPractices
    function Get-WinEvents 
    {
        <#
        .SYNOPSIS
        Gets last 30 days of error & warning events in the application & system logs.
        
        .DESCRIPTION
        Gets last 30 days of error & warning events in the application & system logs.  For performance reasons, only the last 100 log items are retrieved.
        
        .EXAMPLE
        Get-WinEvents
        
        Used in script to return HTML fragment. 
        #>
        [CmdletBinding()]
        param()
        $Logdays = (get-date).AddDays(-30)
        Get-WinEvent -FilterHashTable @{logname='Application','System';Level=2;StartTime=$Logdays} -MaxEvents 250 -ErrorAction SilentlyContinue
    }

    $EventHTMLFragment = Get-WinEvents | ConvertTo-Html -Property TimeCreated,LogName,ProviderName,Id,LevelDisplayName,Message -PreContent "<h3>Event Log Errors:</h3>" -Fragment
    ConvertTo-HTML -PostContent "$EventHTMLFragment" -PreContent "<h2>Server $env:computername</h2>"
}

$healthblock = 
{
    Import-Module ServerManager
    Import-Module BestPractices

    function Get-BPA
    {
        <#
        .SYNOPSIS
        Invokes all best practice analyzer scans on the server and returns results.
        
        .DESCRIPTION
        Invokes all best practice analyzer scans on the server. Waits 5 minutes to allow scan to complete and returns results to the pipeline.
        
        .EXAMPLE
        Get-BPA
        
        Used in script to return HTML fragment. 
        #>
        [CmdletBinding()]
        param()
        #Define hash table for BPA scans to potentially run.
        $ModelsToRun = @() 
        #Find the installed roles of the server and write to hash table. 
        if ((Get-WindowsFeature Application-Server).Installed) 
        { 
        $ModelsToRun += "Microsoft/Windows/ApplicationServer" 
        } 
        
        if ((Get-WindowsFeature AD-Certificate).Installed) 
        { 
        $ModelsToRun += "Microsoft/Windows/CertificateServices" 
        } 
    
        if ((Get-WindowsFeature DHCP).Installed) 
        { 
        $ModelsToRun += "Microsoft/Windows/DHCPServer" 
        } 

        if ((Get-WindowsFeature AD-Domain-Services).Installed) 
        { 
        $ModelsToRun += "Microsoft/Windows/DirectoryServices" 
        } 
        
        if ((Get-WindowsFeature DNS).Installed) 
        { 
        $ModelsToRun += "Microsoft/Windows/DNSServer" 
        } 
        
        if ((Get-WindowsFeature FileAndStorage-Services).Installed) 
        { 
        $ModelsToRun += "Microsoft/Windows/FileServices" 
        } 
    
        if ((Get-WindowsFeature Hyper-V).Installed) 
        { 
        $ModelsToRun += "Microsoft/Windows/Hyper-V" 
        } 
        
        if ((Get-WindowsFeature NPAS).Installed) 
        { 
        $ModelsToRun += "Microsoft/Windows/NPAS" 
        } 
        
        if ((Get-WindowsFeature Remote-Desktop-Services).Installed) 
        { 
        $ModelsToRun += "Microsoft/Windows/TerminalServices" 
        } 
        
        if ((Get-WindowsFeature Web-Server).Installed) 
        { 
        $ModelsToRun += "Microsoft/Windows/WebServer" 
        } 
        
        if ((Get-WindowsFeature OOB-31.39.1.252).Installed) 
        { 
        $ModelsToRun += "Microsoft/Windows/31.39.1.252" 
        }

        if ((Get-WindowsFeature Failover-Clustering).Installed)
        {
        $ModelsToRun += "Microsoft/Windows/ClusterAwareUpdating"
        }

        #Run each BPA scan for all installed roles.
        foreach ($BestPracticesModelId in $ModelsToRun)
        {
        Invoke-BPAModel -ModelId $BestPracticesModelId
        Start-Sleep -Seconds 25
        }    
        Start-Sleep -Seconds 300
        Get-BPAModel | Get-BPAResult | Where-Object {$_.Problem -ne $Null}
    }

    function Get-DriveCapacity
    {
        <#
        .SYNOPSIS
        Returns local drive data and formats HTML report. 
        
        .DESCRIPTION
        Gets drive capacity and formats showing GB totals and free space.
        
        .EXAMPLE
        Get-DriveCapacity
        
        Used in script to return HTML fragment.
        #>
        [CmdletBinding()]
        param()

        $localdrives = get-wmiobject -Class win32_volume | Where-Object { $_.DriveType -eq 3 } | ForEach-Object {Get-PSDrive -LiteralName $_.DriveLetter[0]}
        $localdrives | Select-Object Name,@{Name="Disk Size(GB)";Expression={"{0,8:N0}" -f($_.free/1gb +$_.used/1gb)}},@{Name="Disk Used(GB)";Expression={"{0,8:N0}" -f($_.used/1gb)}},@{Name="Free (%)";Expression={"{0,6:P0}" -f($_.free / ($_.free +$_.used))}}

    }

    function Get-DefragStatus
    {
        <#
        .SYNOPSIS
        Returns drive defrag status 
        
        .DESCRIPTION
        Analyzes local drives and returns wether they are needed to be defraged or not. 
        
        .EXAMPLE
        Get-DriveCapacity
        
        Used in script to return HTML fragment.
        #>
        [CmdletBinding()]
        param()
    
        $localdrives = get-wmiobject -Class win32_volume | Where-Object { $_.DriveType -eq 3 } | ForEach-Object {Get-PSDrive -LiteralName $_.DriveLetter[0]}
        $drivestoanalyze = $localdrives | Select-Object Name
        
        $drives = foreach ($drive in $drivestoanalyze)
        {
            $driveltr = $drive.Name
            $drivenm = $driveltr+":"
            Optimize-Volume -DriveLetter $driveltr -Analyze
            Write-Host "Analyzing $drivenm on $env:computername"
            #Start-Sleep -Seconds 60
            (Get-WmiObject -Class win32_volume -Filter "DriveLetter = '$drivenm'").DefragAnalysis() | Select-Object @{Name="Drive Letter";Expression={$drivenm}},DefragRecommended | Write-Output
        }
        $drives | Write-Output
    }

    

    #Get Output to HTML Fragment format#
    $BPAHTMLFragment = Get-BPA | ConvertTo-Html -Property ModelID,Severity,Title,Problem,Resolution,Help -PreContent "<h3>Best Practices Analyzer Results:</h3>" -Fragment
    $DriveSpaceFragment = Get-DriveCapacity | ConvertTo-HTML -PreContent "<h3>Drive Space Report</h3>" -Fragment
    $DriveDefragFragment = Get-DefragStatus | ConvertTo-HTML -PreContent "<h3>Drive Defragment Status</h3>" -Fragment
    
    #Write final HTML Report#
    ConvertTo-HTML -PostContent "$BPAHTMLFragment","$DriveSpaceFragment","$DriveDefragFragment" -PreContent "<h2>Server $env:computername</h2>"
}


$domainblock = 
{

    Import-Module ServerManager
    Import-Module BestPractices
    if ((Get-WindowsFeature AD-Domain-Services).Installed)
    {

    function Get-DcDiag
    {
        <#
        .SYNOPSIS
        Returns DcDiag results to variable. 
    
        .DESCRIPTION
        Returns DcDiag results to variable in order to export to HTML fragment for use in reporting.
    
        .EXAMPLE
        Get-DcDiag
    
        Used in script to return HTML fragment.
        #>
        
            $Dcdiag = (Dcdiag.exe) -split ('[\r\n]')
            $Results = New-Object Object
                $Results | Add-Member -Type NoteProperty -Name "ServerName" -Value $env:computername
                $Dcdiag | ForEach-Object{ 
             
                    Switch -RegEx ($_) 
                    { 
                        "Starting"      { $TestName   = ($_ -Replace ".*Starting test: ").Trim() } 
                        "passed test|failed test"
                        { 
                            If ($_ -Match "passed test")
                            {  
                                $TestStatus = "Passed" 
                            }  
                            Else 
                            {   
                                $TestStatus = "Failed" 
                            } 
                        } 
                    } 
             
                    If ($TestName -ne $Null -And $TestStatus -ne $Null) 
                    { 
                        $Results | Add-Member -Name $("$TestName".Trim()) -Value $TestStatus -Type NoteProperty -force
                        $TestName = $Null; $TestStatus = $Null      
                    } 
                }       
            $AllDCDiags += $Results
            $AllDcDiags | Write-Output        
    }

    function Get-RepResults
    {
        <#
        .SYNOPSIS
        Returns Repadmin Results results to variable. 
    
        .DESCRIPTION
        Returns Repadmin Results results to variable in order to export to HTML fragment for use in reporting.
    
        .EXAMPLE
        Get-RepResults
    
        Used in script to return HTML fragment.
        #>
        [CmdletBinding()]
        param()
        $repadmin = @()

        $rep = (Invoke-Command -ScriptBlock{repadmin /showrepl /repsto /csv | ConvertFrom-Csv})
 
        $rep | ForEach-Object {
     
        # Define current loop to variable
        $r = $_
 
        # Adding properties to object
        $REPObject = New-Object PSCustomObject
        $REPObject | Add-Member -Type NoteProperty -Name "Destination DCA" -Value $r.'destination dsa'
        $REPObject | Add-Member -Type NoteProperty -Name "Source DSA" -Value $r.'source dsa'
        $REPObject | Add-Member -Type NoteProperty -Name "Source DSA Site" -Value $r."Source DSA Site"
        $REPObject | Add-Member -Type NoteProperty -Name "Last Success Time" -Value $r.'last success time'
        $REPObject | Add-Member -Type NoteProperty -Name "Last Failure Status" -Value $r.'Last Failure Status'
        $REPObject | Add-Member -Type NoteProperty -Name "Last Failure Time" -Value $r.'last failure time'
        $REPObject | Add-Member -Type NoteProperty -Name "Number of failures" -Value $r.'number of failures'
 
        # Adding object to array
        $repadmin += $REPObject
 
        }
        $repadmin | Write-Output
        
    }
    #Get Output to HTML Fragment format#
    $DcDiagFragment = Get-DcDiag | ConvertTo-Html -PreContent "<h3>DcDiag Results:</h3>" -Fragment
    $RepadminFragment = Get-RepResults | ConvertTo-HTML -PreContent "<h3>Replication Health:</h3>" -Fragment
        
    #Write final HTML Report#
    ConvertTo-HTML -PostContent "$DcDiagFragment","$RepadminFragment" -PreContent "<h2>Server $env:computername</h2>"
    }
}

    #Verify report directory exists#
    if (Test-Path -Path $reportdir)
    {
        #Nothing to see here# 
    }
    else 
    {
        New-Item -Path $reportdir -ItemType Directory
    }


ConvertTo-HTML -Head $header -PreContent "<h1>Network Health Report for $domainnm</h1>" | Out-File $reportdir\$report
ConvertTo-HTML -Head $header -PreContent "<h1>Event Log Report for $domainnm</h1>" | Out-File $reportdir\$eventreport
ConvertTo-HTML -Head $header -PreContent "<h1>Domain Health Report for $domainnm</h1>" | Out-File $reportdir\$domainreport

#Script block to run on servers#
foreach ($server in $servers)
{
    $sesh = New-PSSession $server
    Invoke-Command -Session $sesh -ScriptBlock $healthblock | Out-File $reportdir\$report -Append
    Invoke-Command -Session $sesh -ScriptBlock $eventblock | Out-File $reportdir\$eventreport -Append
    Invoke-Command -Session $sesh -ScriptBLock $domainblock | Out-File $reportdir\$domainreport -Append
    Remove-PSSession $sesh
}

#Email final report#
Send-MailMessage -To $mailreceiver -From $mailsender -SmtpServer $mailserver -Subject "Network Health Report for $domainnm" -Body "Please review the attached health report" -Attachments "$reportdir\$report","$reportdir\$eventreport","$reportdir\$domainreport"
$ErrorActionPreference = "Continue"
}