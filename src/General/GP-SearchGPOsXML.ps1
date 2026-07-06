# Purpose: GP-SearchGPOsXML — General-purpose PowerShell utilities.
#   James Wylde


#----------------------------------------------------------------------------------------#
#   Modules

Import-Module GroupPolicy 

#----------------------------------------------------------------------------------------#

#   VARS

Start-Transcript -Path "C:\temp\transcript0.txt" -Force
Start-Transcript -Path "C:\temp\transcript0.txt" -Append
$DomainName = $env:USERDNSDOMAIN 

#$FileOut = 'C:\Temp\Exports\GPOsearch.csv'

#----------------------------------------------------------------------------------------#

#   Search

$string = Read-Host -Prompt "Search: " 

#----------------------------------------------------------------------------------------#

#   GPOs in Domain

Write-Host "Searching GPOs in $DomainName" 
$allGposInDomain = Get-GPO -All -Domain $DomainName 
[string[]] $MatchedGPOList = @()

#----------------------------------------------------------------------------------------#

#   GPO XML search

Write-Host "Searching..." 
foreach ($gpo in $allGposInDomain) { 
    $report = Get-GPOReport -Guid $gpo.Id -ReportType Xml 
    if ($report -match $string) { 
        Write-Host "* Match found: $($gpo.DisplayName) *" -foregroundcolor "Green"
        $MatchedGPOList += "$($gpo.DisplayName)";
    } 
    else { 
        Write-Host "No match: $($gpo.DisplayName)" -foregroundcolor "Red"
    } 
} 
Write-Host " `r`n "
Write-Host "Results: " -foregroundcolor "Yellow"
foreach ($match in $MatchedGPOList) { 
    Write-Host "Match found in: $($match)" -foregroundcolor "Green" 



    #Export-csv c:\temp\export1.csv

#Write-Output $Output | Out-File $FileOut -Encoding utf8 -Append
}

