# Purpose: Get-NexposeReportSortedSevTitleIP — McAfee ePolicy Orchestrator reporting.
Function Get-NexposeReportSortedSevTitleIP {
# Sort by Severity->Title->IP
Add-Type -AssemblyName System.Windows.Forms

$filesavelocation = "K:\Patching\Nexpose\Reports\May-2018\ParsedReports" # update this with the location you want the file saved to
#                          do net enter a trailing '/'
#                          for example to save to your desktop change 'T:' above to
#                          C:\Users\<your username>\Desktop

Function Get-FileName($windowName){  
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.Title = $windowName
    $OpenFileDialog.InitialDirectory = [environment]::getfolderpath("K:\Patching\Nexpose\Reports\May-2018\ParsedReports")
    $OpenFileDialog.filter = "All files (*.*)| *.*"
    $OpenFileDialog.ShowDialog() | Out-Null
    if (!($OpenFileDialog.filename)) {
        Write-Warning "Cancelled"
        break
        }
    $OpenFileDialog.filename
    }

#$file = Get-FileName "Open the combined Nexpose csv file"

$list = @()
$iparray = @()
$ip = ""
$vulcode = ""
$issue = ""
$action = ""
$risk = ""
$issuearray = @("I","","A","R","E")
$match = 0
$csvf1 = Get-FileName "OPEN THE nexpose_csv FILE"
$csvf2 = ''
$comb = @()
$ans = "n"
$ans = Read-Host "Do you have another Nexpose CSV file to add? [y,N] "
if ($ans -eq "Y" -or $ans -eq "y") {
    $csvf2 = Get-FileName "OPEN THE nexpose_csv FILE"
    }

if ($csvf2 -ne '') {
    $comb += Import-Csv $csvf1 -Encoding UTF8 | where {$_."Asset IP Address" -ne "end"}
    $comb += Import-Csv $csvf2 -Encoding UTF8
    }
else {
    $comb = Import-Csv $csvf1 -Encoding UTF8
    }

$tcsv = $comb | Sort-Object -Property @{Expression={$_."Vulnerability Severity Level" -as [int]};Descending=$True}, "Vulnerability Title", "Asset IP Address"
 foreach ($line in $tcsv) {
    if ($line."Vulnerability Test Result Code" -eq "VZ") {continue}
    $issue = $line."Vulnerability Title"
    $ip = $line."Asset IP Address"
    $vulcode = $line."Vulnerability Test Result Code"
    $ecfirst = $line."ecfirst can assist"
    if ($vulcode -eq "VE") {
        $vulcode = "C"
        }
    else {
        $vulcode = "P"
        }
    $action = $line.Solution
    $risk = $line."Vulnerability Severity Level"
    if ($issuearray[0] -eq "I") {
        $issuearray[0] = $issue
        $issuearray[2] = $action
        if ($vulcode -eq "P") {$iparray += "$ip ($vulcode)"}
        else {$iparray += $ip}
        $issuearray[3] = $risk
        $issuearray[4] = $ecfirst
        }
    elseif ($issuearray[0] -eq $issue) {
        foreach ($i in $iparray) {
            if ($vulcode -eq "P") {
                if ($i -eq "$ip ($vulcode)") {
                    $match = 1
                    }
                }
            else {
                if ($i -eq $ip) {
                    $match = 1
                    }
                }
            }
        if ($match -eq 0) {
            if ($vulcode -eq "P") {$iparray += "$ip ($vulcode)"}
            else {$iparray += $ip}
            }
        $match = 0
        }
    else {
        $iparray | ForEach-Object -Process {
            $issuearray[1] += "$_`r"
            }
        $list += New-Object PSObject -Property @{Issue=$issuearray[0];Systems=$issuearray[1];Action=$issuearray[2];ecfirst=$issuearray[4];Sev=$issuearray[3]} | Select-Object Issue,Systems,Action,ecfirst,Sev
        $iparray = @()
        $issuearray = @("I","","A","R","E")
        $issuearray[0] = $issue
        $issuearray[2] = $action
        $issuearray[3] = $risk
        $issuearray[4] = $ecfirst
        if ($vulcode -eq "P") {$iparray += "$ip ($vulcode)"}
        else {$iparray += $ip}
        
        }
    }

Write-Host "Created $filesavelocation\nexpose_cap.csv"
$list | Export-Csv "$filesavelocation\nexpose_cap.csv" -NoTypeInformation -Encoding UTF8
}