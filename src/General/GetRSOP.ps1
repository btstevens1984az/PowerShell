# Purpose: GetRSOP — General-purpose PowerShell utilities.
$serverNames = "dc2","kms","dc4"
$saveLocation = "c:\temp\GPOReports"
$serverNames | foreach-object {
try {
    $computerName = $_
    Get-GPResultantSetOfPolicy -Computer $computerName -User "$computerName\administrator" -Path "$saveLocation\$computerName.htm" -ReportType Html -ErrorAction stop
    Write-Verbose "RSOP complete with userinfo for $_"
    }
catch [System.ArgumentException],[System.Security.Principal.IdentityNotMappedException]
    {
        if ($_.exception.message -like "*no RSoP logging data  for that user on that computer*" -or $_.exception.message -like "*identity references could not be translated*")
        {
            Write-Verbose $_.exception.message
            Write-Verbose "Running RSOP with out user info"
            Get-GPResultantSetOfPolicy -Computer $computerName  -Path "$saveLocation\$computerName.htm" -ReportType Html
        }
    }
}