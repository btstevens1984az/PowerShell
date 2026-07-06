# Purpose: Get-NexposeReport — McAfee ePolicy Orchestrator reporting.
Function Get-NexposeReport {
# Take the CSV created from nexposeXMLparse
# change vulnerability test result codes from VV to VP or VE
# change vulnerability test result code to VZ if accepted
Add-Type -AssemblyName System.Windows.Forms

$filesavelocation = "K:\Patching\Nexpose\Reports\May-2018\ParsedReports" 
# update this with the location you want the file saved to
#                          do net enter a trailing '/'
#                          for example to save to your desktop change 'T:' above to
#                          C:\Users\$env:USERNAME\Desktop


$csv = @()
$vulnarray = @{}

$vulnFile = "$filesavelocation\vulnarray.csv" # location of the vulnerability array

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

Function Build-Vulns($file) {
    $var = @{}
    Import-Csv $file -Encoding UTF8 | ForEach-Object -Process {
        $title = $_."Vulnerability"
        $solution = $_."Action Required"
        $impact = $_."Vulnerability Threat"
        $ecfirst = $_."Assigned"
        $cat = $_."Category"
        $temp = @{"impact" = $impact; "solution" = $solution; "ecfirst" = $ecfirst; "category" = $cat}
        $var.Add($title, $temp)
        }

    return $var
    }

Function Get-Vuln($title, $code) {
    $info = $vulnarray.Get_Item($title)
    $impact = $info.Get_Item("impact")
    $solution = $info.Get_Item("solution")
    $ecfirst = $info.Get_Item("ecfirst")
    $cat = $info.Get_Item("category")
    switch($code) {
        "VE" {$impact = $impact.Replace("<<CANMAY>>", "can")}
        "VP" {$impact = $impact.Replace("<<CANMAY>>", "may")}
        "VZ" {$impact = "The risk of this vulnerability has been accepted"}
        }

    $impact
    $solution
    $ecfirst
    $cat
    }

Function Gen-CVELinks($CVEs) {
    $cvelink = ""
    $CVEs.Split(",") | foreach {
        if ($cvelink -eq "") {$cvelink = "http://web.nvd.nist.gov/view/vuln/detail?vulnId=$_"}
        else {$cvelink += "`nhttp://web.nvd.nist.gov/view/vuln/detail?vulnId=$_"}
        }
    return $cvelink
    }

Function CSV-Build ($ip, $port, $proto, $code, $id, $cve, $sev, $title, $details, $evidence, $impact, $solution, $ref, $ecfirst, $detremed, $cat) {
    $mcsv = (New-Object -TypeName PSObject -Property (@{"Asset IP Address"=$ip;"Service Port"=$port;"Protocol"=$proto;"Vulnerability Test Result Code"=$code;"Vulnerability ID"=$id;"Vulnerability CVE IDs"=$cve;"Vulnerability Severity Level"=$sev;"Vulnerability Title"=$title;"Details"=$details;"Evidence"=$evidence;"Impact"=$impact;"Solution"=$solution;"References"=$ref; "ecfirst can assist"=$ecfirst; "Detailed Remediation"=$detremed; "Category"=$cat}) | Select-Object "Asset IP Address","Service Port","Protocol","Vulnerability Test Result Code","Vulnerability ID","Vulnerability CVE IDs","Vulnerability Severity Level","Vulnerability Title","Details","Evidence","Impact","Solution","References","ecfirst can assist","Detailed Remediation","Category")
    return $mcsv
    }

### end functions ###

$starttime = Get-Date

$missingmatches = ""

# $vulnFile = Get-FileName "OPEN THE VULNERABILITY ARRAY FILE"
$nexposeFile = Get-FileName "OPEN THE nexpose_parsed_csv FILE"

$vulnarray = Build-Vulns $vulnFile

Write-Progress -Activity "Importing CSV"

$mcsv = Import-Csv $nexposeFile -Encoding UTF8

Write-Progress -Activity "Importing CSV" -Completed "Done"

Write-Progress -Activity "Parsing CSV..."

foreach ($item in $mcsv)  {
    $ip = $item."Asset IP Address"
    $port = $item."Service Port"
    $proto = $item."Protocol"
    $code = $item."Vulnerability Test Result Code"
    $id = $item."Vulnerability ID"
    $cve = $item."Vulnerability CVE IDs"
    $sev = $item."Vulnerability Severity Level"
    $title = $item."Vulnerability Title"
    $details = $item."Details"
    $evidence = $item."Evidence"
    $detremed = $item."Detailed Remediation"
    $impact = ""
    $solution = ""
    $ref = ""
    $cat = ""

    Write-Progress -Activity "Parsing CSV..." -Status "Processing $title"

    if ($cve -ne "") {
        if ($cve -notmatch ",") {$ref = "http://web.nvd.nist.gov/view/vuln/detail?vulnId=$cve"}
        else {$ref = Gen-CVELinks($cve)}
        }
    else {$ref = "No NIST reference available"}

    if ($vulnarray.ContainsKey($title)) {
        $res = Get-Vuln $title $code
        $impact = $res[0]
        $solution = $res[1]
        $ecfirst = $res[2]
        $cat = $res[3]
        }
    else {
        Write-Warning "No match for: '$title'"
        if (-not $missingmatches.Contains($title)) {
            $missingmatches += "$title`n"
            }
        }
    if ($ecfirst -eq "ecfirst") {$ecfirst = "Yes"}
    else {$ecfirst = "No"}
    if ($impact -eq "") {Write-Warning "`Missing Impact for: '$title'"}
    elseif ($solution -eq "") {Write-Warning "Missing Solution for: '$title'"}
    elseif ($cat -eq "") {Write-Warning "Missing Category for: '$title'"}
    $csv += CSV-Build $ip $port $proto $code $id $cve $sev $title $details $evidence $impact $solution $ref $ecfirst $detremed $cat
    }

$port = $proto = $code = $id = $cve = $sev = $title = $details = $evidence = $impact = $solution = $ref = $ecfirst = $detremed = $cat = ""
$csv += CSV-Build "end" $port $proto "VZZ" $id $cve "0" $title $details $evidence $impact $solution $ref $ecfirst $detremed $cat

Write-Progress -Activity "Parsing CSV..." -Completed "Done"

$csv | Export-Csv "$filesavelocation\nexpose_csv.csv" -NoTypeInformation -Encoding UTF8
Write-Host "File $filesavelocation\nexpose_csv.csv created"
if ($missingmatches -ne "") {
    $missingmatches | Out-File "$filesavelocation\nexpose-missing.txt" -Encoding utf8
    Write-Host "File $filesavelocation\nexpose-missing.txt created"
    }

$endtime = Get-Date
$lentime = $endtime - $starttime
#Write-Host $lentime
}