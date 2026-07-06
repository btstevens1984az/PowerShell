# Purpose: Get-BestPracticeAnalyzer — Reusable PowerShell function libraries.

# Runs BPA Scans against local computer and returns result to HTML #
Function Get-BestPracticeAnalyzer {

Import-Module ServerManager
Import-Module BestPractices

Function Get-BPA
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
    Start-Sleep -Seconds 10
    }    
    
    #Wait 5 minutes and then pull BPA scan results.
    Start-Sleep -Seconds 300
    Get-BPAModel | Get-BPAResult | Where-Object {$_.Problem -ne $Null}
}

#Define Global Table Header
$Header = @"
<style>
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED;color: #FFFFFF}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
</style>
<title>Server Health Report for $env:computername</title>
"@

#Write final HTML Report
Get-BPA | ConvertTo-HTML -Property ModelID,Severity,Title,Problem,Resolution,Help -PreContent "<H2>Best Practices Analyzer Results:</H2>" -Head $Header | Out-File "C:\Temp\$env:computername-BestPracticeAnalyzerResults.html"
}