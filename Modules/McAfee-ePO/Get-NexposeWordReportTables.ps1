# Purpose: Get-NexposeWordReportTables — McAfee ePolicy Orchestrator reporting.
Function Get-NexposeWordReportTables {
# Reads in Nexpose results CSV and builds remediation tables in a Word doc from them
# (use results from vulnArray and save as a CSV)
#
# byHost Grouping (best for Silver-Platinum){
#  sort by IP->Vulnerability Test Result Code->Vulnerability Severity Level(high->low)->Vulnerability Title
#  }
#
# byVuln Grouping (best for Titanium){
#   sort by Vulnerability Test Result Code->Vulnerability Severity Level(high->low)->Vulnerability Title->IP
#   }
#
#  add end to first cell last line
#
#
#  
# must have a Style template name "Grid Table 6 Colorful - Accent 12"
#
# ***NOTE: Do NOT have any instances of Word open when running this script***
#
#
#b.miller 0913 
Add-Type -AssemblyName System.Windows.Forms

#$ErrorActionPreference = "silentlycontinue"

$filesavelocation = "K:\Patching\Nexpose\Reports\May-2018\ParsedReports" # update this with the location you want the file saved to
#                          do net enter a trailing '/'
#                          for example to save to your desktop change 'T:' above to
#                          C:\Users\<your username>\Desktop

$cols = 2
$rows = 3
$tablenum = 1
$filenum = 1
$DebugPreference = "Continue"

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

Function Get-FolderName($windowName) {
    $openFolder = New-Object System.Windows.Forms.FolderBrowserDialog
    $openFolder.Description = $windowName
    $openFolder.SelectedPath = $filesavelocation
    $res = $openFolder.ShowDialog()
    if ($res -eq "Cancel") {
        Write-Host "Cancelled"
        break
        }
    $openFolder.SelectedPath
    }

function table_maker($iBlock, $mydoc, $mysel, $filenum) {
    $tempfilename = $tempfilenamebase + "_" + $filenum + " nexpose-remed-tables.docx"
    $fname = $tempfilenamebase + "_" + $filenum
     if ($tablenum%64 -eq 0) {
        $mydoc.SaveAs([REF]$tempfilename)
        Write-Debug "SAVED"
        }
       $issue = $iBlock[3]
    $risk = $iBlock[2]
    $detremed = $iBlock[4]

    $myrange = $mysel.Range
    $mydoc.Tables.Add($myrange,$rows,$cols,0,0) | Out-Null
    $mytable = $mydoc.Tables.item($tablenum)

    $mytable.Cell(1,1).WordWrap = $false
    $mytable.Cell(1,1).Range.Text = "Risk"
    $mytable.Cell(1,2).WordWrap = $false
    $mytable.Cell(1,2).Range.Text = $risk
    $mytable.Cell(2,1).WordWrap = $false
    $mytable.Cell(2,1).Range.Text = "Issue"
    $mytable.Cell(2,2).Range.Text = $issue
    $mytable.Cell(3,1).WordWrap = $false
    $mytable.Cell(3,1).Range.Text = "Solution"
    $mytable.Cell(3,2).Range.Text = $detremed
        
    $mytable.Range.Style = "Grid Table 6 Colorful - Accent 12"

    $mytable.Cell(3,1).Column.AutoFit()
    $mytable.Cell(3,2).Column.AutoFit()
    $mytable.Range.Font.Size = 11
   
    $mysel.EndKey(6) | Out-Null
    $mysel.TypeParagraph()
    
    return
    }

function read_line {
    $issue = $_."Vulnerability Title"
    if ($_."Vulnerability Test Result Code" -eq "VP") {
        $type = "potential"
        }
    elseif ($_."Vulnerability Test Result Code" -eq "VE") {
        $type = "confirmed"
        }
    elseif ($_."Vulnerability Test Result Code" -eq "VZ") {
        $type = "accepted"
        }
    $hostIP = $_."Asset IP Address"
    $rating = [int]$_."Vulnerability Severity Level"
    $finding = $_.Impact
    $solution = $_."Detailed Remediation"
        
    if ($rating -ge 8) {
        $rating = "High"
        }
    elseif ($rating -ge 4 -and $rating -le 7) {
         $rating = "Medium"
         }
    elseif ($rating -le 3) {
        $rating = "Low"
        }

    $hostIP #0
    $type #1
    $rating #2
    $issue #3
    $solution #4
    }

function read_line2 ($line) {
    $item = @{}
    $item.Add("issue", $line."Vulnerability Title")
    if ($line."Vulnerability Test Result Code" -eq "VP") {
        $item.Add("type", "potential")
        }
    elseif ($line."Vulnerability Test Result Code" -eq "VE") {
        $item.Add("type", "confirmed")
        }
    elseif ($line."Vulnerability Test Result Code" -eq "VZ") {
        $item.Add("type", "accepted")
        }
    $item.Add("hostIP", $line."Asset IP Address")
    $rating = [int]$line."Vulnerability Severity Level"
    $item.Add("finding", $line.Impact)
    $item.Add("detail", $line.Details)
    $item.Add("evidence", $line.Evidence)
    $item.Add("solution", $line."Detailed Remediation")
    $item.Add("port", $line."Service Port")
    $protocol = $line.Protocol
    $item.Add("protocol", $protocol.ToUpper())
    $item.Add("ref", $line.References)
    
    if ($rating -ge 8) {
        $item.Add("rating", "High")
        }
    elseif ($rating -ge 4 -and $rating -le 7) {
         $item.Add("rating", "Medium")
         }
    elseif ($rating -le 3) {
        $item.Add("rating", "Low")
        }

    return $item
    }

function word_close () {
    $mydoc.Save()
    Write-Debug "Saved and closing"
    $mydoc.Close()
    }

function word_start ($myword) {
    $mydoc = $myword.Documents.Add()
    $mydoc.Convert()
    $mysel = $myword.Selection
    $mysel.Range.Font.Size = 11
    $mysel.Range.Font.NameAscii = "Arial"
    $mysel.TypeParagraph()

    return $mydoc, $mysel
    }

function byHost($csvfile, $mydoc, $mysel, $myword) {
    $filenum = 1
    $tablenum = 1
    $curblock = @()
    $fps = 1
    $lastln = ""
    $curIssue = @()
    $mIssue = @()
    $lastiss = ""
    $csvfile | ForEach-Object -Process {
        $marker = 0
        if ($fps -eq 1) {
            $fps = 0
            $curblock += $_
            $lastln = $_
            }
        else {
            if ($_."Asset IP Address" -eq $lastln."Asset IP Address") {
                $curblock += $_
                $lastln = $_
                }
            elseif ($_."Asset IP Address" -ne $lastln."Asset IP Address") {
                $fsps = 1
                $fcp = 1
                $fpp = 1
                $blocknt = 0
                $curblock | ForEach-Object -Process {
                    $blocknt += 1
                    $curIssue = read_line
                    if ($fsps -eq 1) {
                        $fsps = 0
                        $lastiss = $curIssue[5]
                        }
                                        
                    elseif ($_."Vulnerability Title" -ne $mIssue[3]) {
                        $tissue = $mIssue[3]
                        if ($mIssue[1] -eq "confirmed" -and $fcp -eq 1) {
                            $fcp = 0
                            #$mysel.InsertBreak(7)
                            #$mysel.Range.Font.Bold = 1
                            $hip = $mIssue[0]
                            $mysel.typeText("$hip Confirmed Vulnerability Remediation")
                            $mysel.Style = "Heading 4"
                            $mysel.TypeParagraph()
                            }
                        elseif ($mIssue[1] -eq "potential" -and $fpp -eq 1) {
                            $fpp = 0
                            if ($fcp -eq 1) {
                                #$mysel.InsertBreak(7)
                                }
                            #$mysel.Range.Font.Bold = 1
                            $hip = $mIssue[0]
                            $mysel.typeText("$hip Potential Vulnerability Remediation")
                            $mysel.Style = "Heading 4"
                            $mysel.TypeParagraph()
                            }
                        elseif ($mIssue[1] -eq "accepted" -and $fpp -eq 1) {$marker = 1}
                        if ($marker -ne 1) {
                            Write-Progress -Id 1 -Activity "Creating Tables" -CurrentOperation "$tablenum : $tissue"
                            table_maker $mIssue $mydoc $mysel $filenum
                            $tablenum += 1
                            if ($tablenum -eq 2048) {
                                word_close $mydoc
                                $tablenum = 1
                                $filenum += 1
                                $mydoc, $mysel = word_start $myword
                                Write-Debug "New file started"

                                }
                            $lastiss = $mIssue[5]
                            $mIssue = @()
                            }
                        }

                    $mIssue = $curIssue

                    if ($blocknt -ge $curblock.Count) {
                        if ($mIssue[1] -eq "confirmed" -and $fcp -eq 1) {
                            $fcp = 0
                            #$mysel.InsertBreak(7)
                            #$mysel.Range.Font.Bold = 1
                            $hip = $mIssue[0]
                            $mysel.typeText("$hip Confirmed Vulnerability Remediation")
                            $mysel.Style = "Heading 4"
                            $mysel.TypeParagraph()
                            }
                        elseif ($mIssue[1] -eq "potential" -and $fpp -eq 1) {
                            $fpp = 0
                            if ($fcp -eq 1) {
                                #$mysel.InsertBreak(7)
                                }
                            #$mysel.Range.Font.Bold = 1
                            $hip = $mIssue[0]
                            $mysel.typeText("$hip Potential Vulnerability Remediation")
                            $mysel.Style = "Heading 4"
                            $mysel.TypeParagraph()
                            }

                        Write-Progress -Id 1 -Activity "Creating Tables" -CurrentOperation "$tablenum : $tissue"
                        table_maker $mIssue $mydoc $mysel $filenum
                        $tablenum += 1
                        if ($tablenum -eq 2048) {
                            word_close $mydoc
                            $tablenum = 1
                            $filenum += 1
                            $mydoc, $mysel = word_start $myword
                            Write-Debug "New file started"

                            }
                        $lastiss = $mIssue[5]
                        $mIssue = @()
                        }
                    }
                $curblock = @()
                $curblock += $_
                $lastln = $_
                }
            }
        }
    return $mydoc, $filenum
    }

function byVuln($csvfile, $mydoc, $mysel, $myword) {
    $filenum = 1
    $tablenum = 1
    $curblock = @()
    $mtype = "none"
    $fps=1
    foreach ($line in $csvfile) {
        $curitem = read_line2 $line
        if ($curitem.Get_item('type') -ne $mtype -and $fps -eq 1) {
            $mtype = $curitem.Get_item('type')
            if ($mtype -eq "accepted") {continue}
            $mysel.InsertBreak(7)
            switch($mtype) {
                "confirmed" {$mysel.typeText("Confirmed Vulnerabilities")}
                "potential" {$mysel.typeText("Potential Vulnerabilities")}
                "accepted" {$mysel.typeText("Accepted Vulnerabilities")}
                }
            $mysel.Style = "Heading 4"
            $mysel.TypeParagraph()
            }
        if ($fps -eq 1) {
            $fps = 0
            $curblock += $curitem
            $lastitem = $curitem
            }
        elseif ($curitem.Get_item('issue') -ne $lastitem.Get_item('issue')) {
            $mIssue = @()
            $details = $lastitem.Get_Item("detail")
            $issue = $lastitem.Get_item("issue")
            $finding = $lastitem.Get_Item("finding")
            $solution = $lastitem.Get_Item("solution")
            $ref = $lastitem.Get_Item("ref")
            $rating = $lastitem.Get_Item("rating")
            $thost = ""
            $evidences = ""
            $mIssue += $thost
            $mIssue += $lastitem.Get_Item("type")
            $mIssue += $rating
            $mIssue += $issue
            $mIssue += $solution

            Write-Progress -Id 1 -Activity "Creating Tables" -CurrentOperation "$tablenum : $issue"
            table_maker $mIssue $mydoc $mysel $filenum
            $tablenum += 1
            if ($tablenum -eq 2048) {
                word_close $mydoc
                $tablenum = 1
                $filenum += 1
                $mydoc, $mysel = word_start $myword
                Write-Debug "New file started"

                }
            $curblock = @()
            $curblock += $curitem
            $lastitem = $curitem
            if ($curitem.Get_item('type') -ne $mtype -and $fps -eq 0) {
                $mtype = $curitem.Get_item('type')
                if ($mtype -eq "accepted") {continue}
                $mysel.InsertBreak(7)
                switch($mtype) {
                    "confirmed" {$mysel.typeText("Confirmed Vulnerabilities")}
                    "potential" {$mysel.typeText("Potential Vulnerabilities")}
                    "accepted" {$mysel.typeText("Accepted Vulnerabilities")}
                    }
                $mysel.Style = "Heading 4"
                $mysel.TypeParagraph()
                }
            $details = $tdetails = $issue = $finding = $solution = $ref = $rating = $thost = $evidences = $port = $ports = $hostport = $protocol = $hip = ""
            }
        else {
            $curblock += $curitem
            $lastitem = $curitem
            }
        }

    return $mydoc, $filenum
    }

####End Functions####
$file = Get-FileName "Open the nexpose_csv file"
$msaveloc = Get-FolderName "Select the folder where you want to save the tables"

$tempfilenamebase = "$msaveloc\" + (Get-Date).ToString('M-d-y')

$gtype = 0
while ($gtype -ne 1 -and $gtype -ne 2) {
    $gtype = Read-Host "`nPlease select a Grouping Type:`n1) By Host (Bronze-Platinum)`n2) By Vulnerability (Titanium)`n(-"
    }

$myword = New-Object -ComObject word.application
$myword.Visible = $false
$wsc = $myword.Options.CheckSpellingAsYouType
$wgc = $myword.Options.CheckGrammarAsYouType
$myword.Options.CheckSpellingAsYouType = $false
$myword.Options.CheckGrammarAsYouType = $false

$mydoc, $mysel = word_start $myword

Get-Date

Write-Progress -Id 1 -Activity "Creating Tables"
if ($gtype -eq 1) {
    $csvfile = Import-Csv $file -Encoding UTF8 | Sort-Object -Property "Asset IP Address", "Vulnerability Test Result Code", @{Expression={$_."Vulnerability Severity Level" -as [int]};Descending=$True}, "Vulnerability Title"
    $mydoc, $filenum = byhost $csvfile $mydoc $mysel $myword
    }
elseif($gtype -eq 2) {
    $csvfile = Import-Csv $file -Encoding UTF8 | Sort-Object -Property "Vulnerability Test Result Code", @{Expression={$_."Vulnerability Severity Level" -as [int]};Descending=$True}, "Vulnerability Title", "Asset IP Address"
    $mydoc, $filenum = byVuln $csvfile $mydoc $mysel $myword
    }

Write-Progress -Id 1 -Activity "Creating Tables" -Completed "Done"
$tempfilename = $tempfilenamebase + "_" + $filenum + " nexpose-remed-tables.docx"
$mydoc.SaveAs([REF]$tempfilename)
Write-Debug "SAVED"
$myword.Options.CheckSpellingAsYouType = $wsc
$myword.Options.CheckGrammarAsYouType = $wgc
$myword.Visible = $true

Get-Date
}