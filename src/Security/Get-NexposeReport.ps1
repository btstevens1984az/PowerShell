
Function Get-NexposeReport{
<#
    .SYNOPSIS
        Downloads report once completed.
    .DESCRIPTION
        Downloads report once completed.

    
    .PARAMETER Name
        Name of report you want to download.
    
    .PARAMETER outfile
        file name and directory.
    
    .EXAMPLE
      Get-NexposeReport -Name reportname -$outfile .\directory\report.csv

#>
Param([String]$Name, [string] $outfile)
$report = Get-NexposeReportListing -Name $Name
# Check that the report is generated and loop until it is or stop if it errored out.
While($report.status -ne 'Generated'){
    if ($report.status -eq 'Failed' -or $report.status -eq 'Aborted' -or $report.status -eq 'Unknown'){
    Write-Host "Report Failed: $report.status" -ForegroundColor Red
    break
    
    }
    sleep 10
    $report = Get-NexposeReportListing -Name $Name
}

$cookie = New-Object System.Net.Cookie
$cookie.Name = 'nexposeCCSessionID'
$cookie.Value = "$SCRIPT:session_id"
$cookie.Domain = "$server"

$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$session.Cookies.Add($cookie)
$directory = $report.'report-URI'
Invoke-WebRequest https://$SCRIPT:server$directory -WebSession $session -OutFile $outfile
Write-Host "Report saved successfully" -ForegroundColor Green

}