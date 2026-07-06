# Purpose: Get-NexposeExcelCountReport — McAfee ePolicy Orchestrator reporting.
Function Get-NexposeExcelCountReport {
# Parses Nexpose_csv and calculates counts; creats a spreadsheet for totals and uniques
# Provide a list of IP's (IP only, each on a single line) in a file for calculating the Top IP counts
#
#b.miller 1016
Add-Type -AssemblyName System.Windows.Forms

$filesavelocation = "K:\Patching\Nexpose\Reports\May-2018\ParsedReports" 
# update this with the location you want the file saved to
#                          do not enter a trailing '/'
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

Function Build-SystemCounts ($allipsheet, $uips, $tc, $thc, $tmc, $tlc, $uc, $uhc, $umc, $ulc, $tips, $impacts) {
    $r = 1
    $allipsheet.Cells.Item($r, 1) = "IP Address"
    $allipsheet.Cells.Item($r, 2) = "High"
    $allipsheet.Cells.Item($r, 3) = "Medium"
    $allipsheet.Cells.Item($r, 4) = "Low"
    $a = $allipsheet.Range("A1:D1").Interior.ColorIndex = 23
    $a = $allipsheet.Range("A1:D1").Font.Bold = $True
    $r +=1
    foreach ($line in $uips.GetEnumerator()) {
        $ip = $line.Key
        $data = $line.Value
        $hc = $data[0]
        $mc = $data[1]
        $lc = $data[2]
        $allipsheet.Cells.Item($r, 1) = $ip
        $allipsheet.Cells.Item($r, 2) = $hc
        $allipsheet.Cells.Item($r, 3) = $mc
        $allipsheet.Cells.Item($r, 4) = $lc
        if ($r % 2 -ne 0) {
            $a = $allipsheet.Range("A$r"+":D$r").Interior.ColorIndex = 37
            }
        $a = $allipsheet.Range("A$r"+":D$r").Borders.LineStyle = 1
        $r += 1
        }
    $a = $allipsheet.Columns("A:D").AutoFit()
    $a = $allipsheet.UsedRange.Borders.LineStyle = 1

    $r = 1
    $allipsheet.Cells.Item($r, 6) = "Total"
    $a = $allipsheet.Cells.Item($r, 6).Interior.ColorIndex = 23
    $a = $allipsheet.Range("F$r").HorizontalAlignment = -4108
    $allipsheet.Cells.Item($r, 7) = "Total High"
    $a = $allipsheet.Cells.Item($r, 7).Interior.ColorIndex = 3
    $allipsheet.Cells.Item($r, 8) = "Total Medium"
    $a = $allipsheet.Cells.Item($r, 8).Interior.ColorIndex = 45
    $allipsheet.Cells.Item($r, 9) = "Total Low"
    $a = $allipsheet.Cells.Item($r, 9).Interior.ColorIndex = 43
    $a = $allipsheet.Range("F$r"+":I$r").Borders.LineStyle = 1
    $a = $allipsheet.Range("F$r"+":I$r").Font.Bold = $True
    $r +=1
    $allipsheet.Cells.Item($r, 6) = $tc
    $allipsheet.Cells.Item($r, 7) = $thc
    $allipsheet.Cells.Item($r, 8) = $tmc
    $allipsheet.Cells.Item($r, 9) = $tlc
    $a = $allipsheet.Range("F$r"+":I$r").Borders.LineStyle = 1

    $r = 4
    $allipsheet.Cells.Item($r, 6) = "Unique Total"
    $a = $allipsheet.Cells.Item($r, 6).Interior.ColorIndex = 23
    $a = $allipsheet.Range("F$r").HorizontalAlignment = -4108
    $allipsheet.Cells.Item($r, 7) = "Unique High"
    $a = $allipsheet.Cells.Item($r, 7).Interior.ColorIndex = 3
    $allipsheet.Cells.Item($r, 8) = "Unique Medium"
    $a = $allipsheet.Cells.Item($r, 8).Interior.ColorIndex = 45
    $allipsheet.Cells.Item($r, 9) = "Unique Low"
    $a = $allipsheet.Cells.Item($r, 9).Interior.ColorIndex = 43
    $a = $allipsheet.Range("F$r"+":I$r").Borders.LineStyle = 1
    $a = $allipsheet.Range("F$r"+":I$r").Font.Bold = $True
    $r +=1
    $allipsheet.Cells.Item($r, 6) = $uc
    $allipsheet.Cells.Item($r, 7) = $uhc
    $allipsheet.Cells.Item($r, 8) = $umc
    $allipsheet.Cells.Item($r, 9) = $ulc
    $a = $allipsheet.Range("F$r"+":I$r").Borders.LineStyle = 1

    $r = 7
    $allipsheet.Cells.Item($r, 6) = "Top Risk IP Address"
    $a = $allipsheet.Cells.Item($r, 6).Interior.ColorIndex = 3
    $allipsheet.Cells.Item($r, 7) = "High"
    $a = $allipsheet.Cells.Item($r, 7).Interior.ColorIndex = 3
    $allipsheet.Cells.Item($r, 8) = "Medium"
    $a = $allipsheet.Cells.Item($r, 8).Interior.ColorIndex = 45
    $allipsheet.Cells.Item($r, 9) = "Low"
    $a = $allipsheet.Cells.Item($r, 9).Interior.ColorIndex = 43
    $a = $allipsheet.Range("F$r"+":I$r").Borders.LineStyle = 1
    $a = $allipsheet.Range("F$r"+":I$r").Font.Bold = $True
    $r +=1
    foreach ($line in $tips.GetEnumerator()) {
        $ip = $line.Key
        $data = $line.Value
        $hc = $data[0]
        $mc = $data[1]
        $lc = $data[2]
        $allipsheet.Cells.Item($r, 6) = $ip
        $allipsheet.Cells.Item($r, 7) = $hc
        $allipsheet.Cells.Item($r, 8) = $mc
        $allipsheet.Cells.Item($r, 9) = $lc
        if ($r % 2 -ne 0) {
            $a = $allipsheet.Range("F$r"+":I$r").Interior.ColorIndex = 37
            }
        $a = $allipsheet.Range("F$r"+":I$r").Borders.LineStyle = 1
        $r += 1
        }
    $a = $allipsheet.Columns("F:I").AutoFit()

    $r = 1
    if ($impacts.Count -lt 10) {$allipsheet.Cells.Item($r, 11) = "Issue Impacts"}
    else {$allipsheet.Cells.Item($r, 11) = "Top 10 Issue Impacts"}
    $a = $allipsheet.Range("K1").HorizontalAlignment = -4108
    $a = $allipsheet.Cells.Item($r, 11).Interior.ColorIndex = 23
    $a = $allipsheet.Range("K$r").Borders.LineStyle = 1
    $a = $allipsheet.Range("K$r").Font.Bold = $True
    $r +=1
    foreach ($item in $impacts) {
        $allipsheet.Cells.Item($r, 11) = $item
        if ($r % 2 -ne 0) {
            $a = $allipsheet.Range("K$r").Interior.ColorIndex = 37
            }
        $a = $allipsheet.Range("K$r").Borders.LineStyle = 1
        $r += 1
        }

    $a = $allipsheet.Columns("K").ColumnWidth = 118
    $a = $allipsheet.Range("K2:K$r").WrapText = $True


    $allipsheet.Cells.Item(17, 11) = "Tab Index"
    $a = $allipsheet.Cells.Item(17, 11).Interior.ColorIndex = 20
    $a = $allipsheet.Range("K17").HorizontalAlignment = -4108
    $a = $allipsheet.Range("K17").Font.Bold = $True
    $allipsheet.Cells.Item(18, 11) = "`nUnique Issues  -:-  Unique issues found across all scanned systems"
    $allipsheet.Cells.Item(19, 11) = "`nIssues by Majority Type  -:-  From the Unique Issues, a listing of those that are the same 'type' (missing patch, configuration item, etc) that represent the majority of the issues found"
    $allipsheet.Cells.Item(20, 11) = "`nSubset of Majority Items  -:-  From the Majority Type, a listing of those that are the same application, vendor, service, etc that are responsible for the bulk of the Majority issues"
    $allipsheet.Cells.Item(21, 11) = "`nAll Issues  -:-  All issues identified. May include 'duplicate' findings (same issue/system, different ports)"
    $allipsheet.Cells.Item(22, 11) = "`nHigh Risk Issues  -:-  All 'High' risk issues identified"
    $allipsheet.Cells.Item(23, 11) = "`nMedium Risk Issues  -:-  All 'Medium' risk issues identified"
    $allipsheet.Cells.Item(24, 11) = "`nLow Risk Issues  -:-  All 'Low' risk issues identified"
    $a = $allipsheet.Range("K18:K24").WrapText = $True
    #$a = $allipsheet.Rows("18:24").AutoFit()

    $a = $allipsheet.Range("K17:K24").Borders.LineStyle = 1

    $now = (Get-Date).ToLongDateString() 
    $allipsheet.Cells.Item(25, 12) = "Generated by ecfirst on $now"

    return $allipsheet
    }

Function Build-Totals($totalsheet, $total, $type="Total") {
    $r = 1
    $totalsheet.Cells.Item($r, 1) = "IP Address"
    $totalsheet.Cells.Item($r, 2) = "Issue"
    $totalsheet.Cells.Item($r, 3) = "Impact"
    $totalsheet.Cells.Item($r, 4) = "Issue Details"
    $totalsheet.Cells.Item($r, 5) = "Evidence"
    $totalsheet.Cells.Item($r, 6) = "Remediation"
    $totalsheet.Cells.Item($r, 7) = "Risk"
    $totalsheet.Cells.Item($r, 8) = "Category"
    $a = $totalsheet.Range("A1:H1").Interior.ColorIndex = 23
    $a = $totalsheet.Range("A1:H1").Font.Bold = $True
    $a = $totalsheet.Range("A$r"+":H$r").Borders.LineStyle = 1
    $r +=1
    foreach ($line in $total) {
        $risk = Change-Risk $line."Vulnerability Severity Level"
        $totalsheet.Cells.Item($r, 1) = $line."Asset IP Address"
        $totalsheet.Cells.Item($r, 2) = $line."Vulnerability Title"
        $totalsheet.Cells.Item($r, 3) = $line."Impact"
        $totalsheet.Cells.Item($r, 4) = $line."Details"
        $totalsheet.Cells.Item($r, 5) = $line."Evidence"
        $totalsheet.Cells.Item($r, 6) = $line."Detailed Remediation"
        $totalsheet.Cells.Item($r, 7) = $risk
        $totalsheet.Cells.Item($r, 8) = $line."Category"
        if ($r % 2 -ne 0) {
            $a = $totalsheet.Range("A$r"+":H$r").Interior.ColorIndex = 37
            }
        $a = $totalsheet.Range("A$r"+":H$r").Borders.LineStyle = 1
        $r +=1
        if ($r%100 -eq 0) {Write-Progress -Activity "Creating nexpose_data spreadsheet..." -Status "Building $type #$r" -Id 1}
        }
    $a = $totalsheet.Columns("A:B").AutoFit()
    $a = $totalsheet.Columns("C:F").ColumnWidth = 36
    $a = $totalsheet.UsedRange.RowHeight = 18
    return $totalsheet
    }

Function Build-Uniques($uniquesheet, $unique) {
    $r = 1
    $uniquesheet.Cells.Item($r, 1) = "Risk"
    $uniquesheet.Cells.Item($r, 2) = "Issue"
    $uniquesheet.Cells.Item($r, 3) = "Impact"
    $uniquesheet.Cells.Item($r, 4) = "Remediation"
    $uniquesheet.Cells.Item($r, 5) = "Category"
    $a = $uniquesheet.Range("A1:E1").Interior.ColorIndex = 23
    $a = $uniquesheet.Range("A1:E1").Font.Bold = $True
    $a = $uniquesheet.Range("A$r"+":E$r").Borders.LineStyle = 1
    $r +=1
    foreach ($line in $unique) {
        $risk = Change-Risk $line."Vulnerability Severity Level"
        $uniquesheet.Cells.Item($r, 1) = $risk
        $uniquesheet.Cells.Item($r, 2) = $line."Vulnerability Title"
        $uniquesheet.Cells.Item($r, 3) = $line."Impact"
        $uniquesheet.Cells.Item($r, 4) = $line."Solution"
        $uniquesheet.Cells.Item($r, 5) = $line."Category"
        if ($r % 2 -ne 0) {
            $a = $uniquesheet.Range("A$r"+":E$r").Interior.ColorIndex = 37
            }
        $a = $uniquesheet.Range("A$r"+":E$r").Borders.LineStyle = 1
        $r +=1
        if ($r%100 -eq 0) {Write-Progress -Activity "Creating nexpose_data spreadsheet..." -Status "Building Unique #$r" -Id 1}
        }
    $a = $uniquesheet.Columns("A:B").AutoFit()
    $a = $uniquesheet.Columns("C:D").ColumnWidth = 72
    return $uniquesheet
    }

Function Build-Majority($majoritysheet, $unique, $ood, $isc, $iwc) {
    $win = Get-Win $ood $isc $iwc
    $r = 1
    $majoritysheet.Cells.Item($r, 1) = "Risk"
    $majoritysheet.Cells.Item($r, 2) = "Issue"
    $majoritysheet.Cells.Item($r, 3) = "Impact"
    $majoritysheet.Cells.Item($r, 4) = "Remediation"
    $majoritysheet.Cells.Item($r, 5) = "Category"
    $a = $majoritysheet.Range("A1:E1").Interior.ColorIndex = 23
    $a = $majoritysheet.Range("A1:E1").Font.Bold = $True
    $a = $majoritysheet.Range("A$r"+":E$r").Borders.LineStyle = 1
    $r +=1
    foreach ($line in $unique) {
        if ($win -notmatch $line."Category") {continue}
        $risk = Change-Risk $line."Vulnerability Severity Level"
        $majoritysheet.Cells.Item($r, 1) = $risk
        $majoritysheet.Cells.Item($r, 2) = $line."Vulnerability Title"
        $majoritysheet.Cells.Item($r, 3) = $line."Impact"
        $majoritysheet.Cells.Item($r, 4) = $line."Solution"
        $majoritysheet.Cells.Item($r, 5) = $line."Category"
        if ($r % 2 -ne 0) {
            $a = $majoritysheet.Range("A$r"+":E$r").Interior.ColorIndex = 37
            }
        $a = $majoritysheet.Range("A$r"+":E$r").Borders.LineStyle = 1
        $r +=1
        if ($r%100 -eq 0) {Write-Progress -Activity "Creating nexpose_data spreadsheet..." -Status "Building Majority #$r" -Id 1}
        }
    $a = $majoritysheet.Columns("A:B").AutoFit()
    $a = $majoritysheet.Columns("C:D").ColumnWidth = 72
    return $majoritysheet
    }

Function Get-Win($ood, $isc, $iwc) {
    $win = ""
    if ([int]$ood -gt [int]$isc -and [int]$ood -gt [int]$iwc) {$win = "OOD"}
    elseif ([int]$isc -gt [int]$ood -and [int]$isc -gt [int]$iwc) {$win = "ISC"}
    elseif ([int]$iwc -gt [int]$ood -and [int]$iwc -gt [int]$isc) {$win = "IWC"}
    if ($win -eq "") {
        if ([int]$ood -eq [int]$isc) {$win = "OOD ISC"}
        elseif ([int]$ood -eq [int]$iwc) {$win = "OOD IWC"}
        elseif ([int]$isc -eq [int]$iwc) {$win = "ISC IWC"}
        }
    return $win
    }

Function Change-Risk($score) {
    $risk = ""
    if ([int]$score -ge 8) {$risk = "High"}
    elseif ([int]$score -le 3) {$risk = "Low"}
    else {$risk = "Medium"}
    return $risk
    }

Function Build-HML ($total, $highsheet, $mediumsheet, $lowsheet) {
    $high = $medium = $low = ""
    $high = $total | Select-Object "Asset IP Address", "Service Port", "Protocol", "Vulnerability Severity Level", "Vulnerability Title", "Details", "Evidence", "Impact", "Solution", "References", "Detailed Remediation", "Category"| where {$_."Vulnerability Severity Level" -as [int] -ge 8}
    $medium = $total | Select-Object "Asset IP Address", "Service Port", "Protocol", "Vulnerability Severity Level", "Vulnerability Title", "Details", "Evidence", "Impact", "Solution", "References", "Detailed Remediation", "Category"| where {$_."Vulnerability Severity Level" -as [int] -le 7 -and $_."Vulnerability Severity Level" -as [int] -ge 4}
    $low = $total | Select-Object "Asset IP Address", "Service Port", "Protocol", "Vulnerability Severity Level", "Vulnerability Title", "Details", "Evidence", "Impact", "Solution", "References", "Detailed Remediation", "Category"| where {$_."Vulnerability Severity Level" -as [int] -le 3}
    
    $highsheet = Build-Totals $highsheet $high "High"
    $mediumsheet = Build-Totals $mediumsheet $medium "Medium"
    $lowsheet = Build-Totals $lowsheet $low "Low"
    
    $highsheet
    $mediumsheet
    $lowsheet
    }

Function Build-Impacts ($unique) {
    $temp = @{}
    $impacts = @()
    $ranked = @()

    foreach ($line in $unique) {
        $impact = $line.Impact
        if (-not $temp.Contains($impact)) {$temp.Add($impact, 0)}
        $score = $temp[$impact]
        $score += 1
        $temp[$impact] = $score
        }

    foreach ($line in $temp.GetEnumerator()) {
        $impact = $line.Key
        $score = $line.Value
        $p = @{'Impact' = $impact; 'Score' = $score}
        $o = New-Object -TypeName PSObject -Property $p
        $ranked += $o
        }

    $t = $ranked | Sort-Object @{Expression={$_."Score" -as [int]}; Descending=$True}, "Impact"

    foreach ($item in $t) {
        if ($impacts.Count -ge 10) {continue}
        $impacts += $item.Impact + " [" + $item.Score + " instances]"
        }

    return $impacts
    }

### End Functions ###

$tt = $total = $unique = ""
$tc = $uc = $thc = $tmc = $tlc = $uhc = $umc = $ulc = $uhmc = $ood = $isc = $iwc = 0
$uips = [ordered]@{}
$tips = [ordered]@{}
$impacts =@()

$mfile = Get-FileName "OPEN THE nexpose_csv FILE"
$ipfile = Get-FileName "OPEN THE list of Top IP Addresses"

Write-Progress -Activity "Importing CSV..."

$mcsv = Import-Csv $mfile | Select-Object "Asset IP Address", "Service Port", "Protocol", "Vulnerability Severity Level", "Vulnerability Title", "Details", "Evidence", "Impact", "Solution", "References", "Detailed Remediation", "Category"| where {$_."Asset IP Address" -ne "end"}

Write-Progress -Activity "Importing CSV..." -Completed "Done"


Write-Progress -Activity "Processing counts..."

$tt = $mcsv | Sort-Object "Asset IP Address", "Vulnerability Title", "Protocol", @{Expression={$_."Vulnerability Severity Level" -as [int]}} -Unique

$total = $tt | Sort-Object @{Expression={$_."Vulnerability Severity Level" -as [int]}; Descending=$True}, "Vulnerability Title" 

$tt =  $total | Select-Object "Vulnerability Severity Level", "Vulnerability Title", "Impact", "Solution", "Category" | Sort-Object "Vulnerability Title", @{Expression={$_."Vulnerability Severity Level" -as [int]}} -Unique

$unique = $tt | Sort-Object @{Expression={$_."Vulnerability Severity Level" -as [int]}; Descending=$True}, "Vulnerability Title"

$tc = ($total | Measure-Object).count
$uc = ($unique | Measure-Object).Count

$thc = ($total | where {$_."Vulnerability Severity Level" -as [int] -ge 8} | Measure-Object).Count
$tmc = ($total | where {$_."Vulnerability Severity Level" -as [int] -le 7 -and $_."Vulnerability Severity Level" -as [int] -ge 4} | Measure-Object).Count
$tlc = ($total | where {$_."Vulnerability Severity Level" -as [int] -le 3} | Measure-Object).Count

$uhc = ($unique | where {$_."Vulnerability Severity Level" -as [int] -ge 8} | Measure-Object).Count
$umc = ($unique | where {$_."Vulnerability Severity Level" -as [int] -le 7 -and $_."Vulnerability Severity Level" -as [int] -ge 4} | Measure-Object).Count
$ulc = ($unique | where {$_."Vulnerability Severity Level" -as [int] -le 3} | Measure-Object).Count
$uhmc = [int]$uhc + [int]$umc

foreach ($item in $unique) {
    if ($item.Category -eq "OOD") {$ood += 1}
    elseif ($item.Category -eq "ISC") {$isc += 1}
    elseif ($item.Category -eq "IWC") {$iwc += 1}
    }

Write-Progress -Activity "Processing counts..." -Completed "Done"

Write-Host ""
Write-Host "Total Count: $tc"
Write-Host "Total Highs: $thc"
Write-Host "Total Mediums: $tmc"
Write-Host "Total Lows: $tlc"
Write-Host ""
Write-Host "Unique Count: $uc"
Write-Host "Unique High/Medium: $uhmc"
Write-Host ""
Write-Host ""
Write-Host "OOD Count: $ood"
Write-Host "ISC Count: $isc"
Write-Host "IWC Count: $iwc"
Write-Host ""

Write-Progress -Activity "Processing Top IP's..."

$mips = Get-Content $ipfile
$impacts = Build-Impacts $unique

foreach ($item in $total) {
    $score = $hc = $mc = $lc = ""
    $cip = $item."Asset IP Address"
    if ($uips.Contains($cip)) {$data = $uips[$cip]}
    else {$data = @(0,0,0)}
    $hc = $data[0]
    $mc = $data[1]
    $lc = $data[2]
    $score = $item."Vulnerability Severity Level"
    if ($score -as [int] -ge 8) {$hc += 1}
    elseif ($score -as [int] -le 7 -and $score -as [int] -ge 4) {$mc += 1}
    else {$lc += 1}
    $data = @($hc,$mc,$lc)
    if ($uips.Contains($cip)) {$uips.Set_Item($cip, $data)}
    else {$uips.Add($cip, $data)}
    }

foreach ($ip in $mips) {
    $data = @(0,0,0)
    if ($uips.Contains($ip)) {$data = $uips[$ip]}
    $tips.Add($ip, $data)
    }

Write-Progress -Activity "Processing Top IP's..." -Completed "Done"
Write-Host ""

Write-Progress -Activity "Creating nexpose_data spreadsheet..." -Id 1

$myexcel = New-Object -ComObject Excel.Application
$myexcel.visible = $False
$mworkbook = $myexcel.Workbooks.Add()
$a = $mworkbook.Worksheets.Add() #2
$a = $mworkbook.Worksheets.Add() #3
$a = $mworkbook.Worksheets.Add() #4
$a = $mworkbook.Worksheets.Add() #5
$a = $mworkbook.Worksheets.Add() #6
$a = $mworkbook.Worksheets.Add() #7
$a = $mworkbook.Worksheets.Add() #8
$allipsheet = $mworkbook.Worksheets.Item(1)
$allipsheet.Name = "Executive Summary"
$totalsheet = $mworkbook.Worksheets.Item(5)
$totalsheet.Name = "All Issues"
$uniquesheet = $mworkbook.Worksheets.Item(2)
$uniquesheet.Name = "Unique Issues"
$majoritysheet = $mworkbook.Worksheets.Item(3)
$majoritysheet.Name = "Issues by Majority Type"
$subsheet = $mworkbook.Worksheets.Item(4)
$subsheet.Name = "Subset of Majority Issues"
$highsheet = $mworkbook.Worksheets.Item(6)
$highsheet.Name = "High Risk Issues"
$mediumsheet = $mworkbook.Worksheets.Item(7)
$mediumsheet.Name = "Medium Risk Issues"
$lowsheet = $mworkbook.Worksheets.Item(8)
$lowsheet.Name = "Low Risk Issues"

Write-Progress -Activity "Creating nexpose_data spreadsheet..." -Status "Building Exec Summary" -Id 1

$allipsheet = Build-SystemCounts $allipsheet $uips $tc $thc $tmc $tlc $uc $uhc $umc $ulc $tips $impacts

Write-Progress -Activity "Creating nexpose_data spreadsheet..." -Status "Building Total..." -Id 1

$totalsheet = Build-Totals $totalsheet $total

Write-Progress -Activity "Creating nexpose_data spreadsheet..." -Status "Building Unique..." -Id 1

$uniquesheet = Build-Uniques $uniquesheet $unique

Write-Progress -Activity "Creating nexpose_data spreadsheet..." -Status "Building Majority..." -Id 1

$majoritysheet = Build-Majority $majoritysheet $unique $ood $isc $iwc

Write-Progress -Activity "Creating nexpose_data spreadsheet..." -Status "Building High, Medium, Low..." -Id 1

$highsheet, $mediumsheet, $lowsheet = Build-HML $total $highsheet $mediumsheet $lowsheet

$mworkbook.saveas("$filesavelocation\nexpose_data.xlsx")
$myexcel.Quit()

Write-Progress -Activity "Creating nexpose_data spreadsheet..." -Completed "Done" -Id 1

Write-Host "File $filesavelocation\nexpose_data.xlsx created"
}