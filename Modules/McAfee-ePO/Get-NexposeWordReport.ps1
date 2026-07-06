# Purpose: Get-NexposeWordReport — McAfee ePolicy Orchestrator reporting.
Function Get-NexposeWordReport {
# Reads in Nexpose results CSV and builds tables in a Word doc from them
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
# Also requires a "Table Style" named "VulnRes" to exist within your Word .dot
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

$cols = 3
$rows = 5
$filenum = 1
$DebugPreference = "Continue"

Function Get-FileName($windowName){  
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.Title = $windowName
    $OpenFileDialog.InitialDirectory = [environment]::getfolderpath("K:\Patching\Nexpose\Reports\May-2018\ParsedReports")
    $OpenFileDialog.filter = "All files (*.*)| *.*"
    $OpenFileDialog.ShowDialog() | Out-Null
    if (!($OpenFileDialog.filename)) {
        Write-Host "Cancelled"
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
    $tempfilename = $tempfilenamebase + "_" + $filenum + " nexpose-tables.docx"
    if ($tablenum%64 -eq 0) {
        $mydoc.SaveAs([REF]$tempfilename)
        Write-Debug "SAVED"
        }
    $issue = $iBlock.Get_Item("issue")
    $rating = $iBlock.Get_Item("rating")
    $type = $iBlock.Get_Item("type")
    

    $myrange = $mysel.Range
    $mydoc.Tables.Add($myrange,$rows,$cols,0,0) | Out-Null
    $mytable = $mydoc.Tables.item($tablenum)

    $mytable.Cell(1,1).WordWrap = $false
    $mytable.Cell(1,1).Range.Text = "Risk:`n`n$rating"
    $mytable.Cell(1,2).WordWrap = $false
    $mytable.Cell(1,2).Range.Text = "Issue"
    $mytable.Cell(1,3).Range.Text = $issue
    $mytable.Cell(2,1).WordWrap = $false
    $mytable.Cell(2,1).Range.Text = "Host(s) Affected`n"
    $mytable.Cell(2,2).WordWrap = $false
    $mytable.Cell(2,2).Range.Text = "Impact"
    $mytable.Cell(2,3).Range.Text = $iBlock.Get_Item("finding")
    $mytable.Cell(3,1).Range.Text = $iBlock.Get_Item("hostIP")
    $mytable.Cell(3,2).WordWrap = $false
    $mytable.Cell(3,2).Range.Text = "Details"
    $mytable.Cell(3,3).WordWrap = $true
    $mytable.Cell(3,3).Range.Text = $iBlock.Get_Item("detail")
    if ($gtype -ne 2) {
        $mytable.Cell(4,1).Range.Font.NameAscii = "Arial"
        $mytable.Cell(4,1).WordWrap = $false
        $mytable.Cell(4,1).Range.Text = "Port(s)`n"
        }
    else {
        $mytable.Cell(4,1).Range.Text = ""
        }
    $mytable.Cell(4,2).Range.Font.NameAscii = "Arial"
    $mytable.Cell(4,2).WordWrap = $false
    $mytable.Cell(4,2).Range.Text = "Solution"
    $mytable.Cell(4,3).Range.Text = $iBlock.Get_Item("solution")
    if ($gtype -ne 2) {
        $mytable.Cell(5,1).Range.Text = $iBlock.Get_Item("port")
        }
    else {
        $mytable.Cell(5,1).Range.Text = ""
        }
    $mytable.Cell(5,2).WordWrap = $false
    $mytable.Cell(5,2).Range.Text = "Reference`n"
    $mytable.Cell(5,3).Range.Text = $iBlock.Get_Item("ref")
    
    switch ($rating) {
        "High" {$mytable.Range.Style = "VulnRes-High"}
        "Medium" {$mytable.Range.Style = "VulnRes-Medium"}
        "Low" {$mytable.Range.Style = "VulnRes-Low"}
        }
    if ($type -eq "accepted") {
        $mytable.Range.Style = "VulnRes-Accepted"
        }

    if ($gtype -eq 1) {
        $mytable.Cell(3,3).Column.PreferredWidthType = 3
        $mytable.Cell(3,3).Column.PreferredWidth = 320.4
        $mytable.Cell(5,2).Column.PreferredWidthType = 3
        $mytable.Cell(5,2).Column.PreferredWidth = 72
        $mytable.Cell(2,1).Column.PreferredWidthType = 3
        $mytable.Cell(2,1).Column.PreferredWidth = 96
        $mytable.Range.Font.Size = 11
        }
    elseif ($gtype -eq 2) {
        $mytable.Cell(5,1).Merge($mytable.Cell(4,1))
        $mytable.Cell(4,1).Merge($mytable.Cell(3,1))
        $mytable.Cell(3,3).Column.PreferredWidthType = 3
        $mytable.Cell(3,3).Column.PreferredWidth = 300.4
        $mytable.Cell(5,2).Column.PreferredWidthType = 3
        $mytable.Cell(5,2).Column.PreferredWidth = 64
        $mytable.Cell(2,1).Column.PreferredWidthType = 3
        $mytable.Cell(2,1).Column.PreferredWidth = 124
        $mytable.Range.Font.Size = 11
        $mytable.Cell(3,1).Range.Font.Size = 9
        }
   
    $mysel.EndKey(6) | Out-Null
    $mysel.TypeParagraph()
    
    return
    }

function read_line ($line) {
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
    $item.Add("solution", $line.Solution)
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

function info_clean ($det) {
    if ($det.Contains("`*")) {
        $det = $det.Replace("`*", "```*")
        }
    if ($det.Contains("`+")) {
        $det = $det.Replace("`+", "```+")
        }
    if ($det.Contains("`?")) {
        $det = $det.Replace("`?", "```?")
        }
    if ($det.Contains("`\")) {
        $det = $det.Replace("`\", "`\`\")
        }
    if ($det.Contains("`[")) {
        $det = $det.Replace("`[", "`\`[")
        }
    if ($det.Contains("`(")) {
        $det = $det.Replace("`(", "`\`(")
        }
    if ($det.Contains("`)")) {
        $det = $det.Replace("`)", "`\`)")
        }
    if ($det.Contains("`n`n")) {
        $det = $det.Replace("`n`n", "`n")
        }
    return $det
    }

function clean_info ($det) {

    if ($det.Contains("```*")) {
        $det = $det.Replace("```*", "`*")
        }
    if ($det.Contains("```+")) {
        $det = $det.Replace("```+", "`+")
        }
    if ($det.Contains("```?")) {
        $det = $det.Replace("```?", "`?")
        }
    if ($det.Contains("`\`\")) {
        $det = $det.Replace("`\`\", "`\")
        }
    if ($det.Contains("`\`[")) {
        $det = $det.Replace("`\`[", "`[")
        }
    if ($det.Contains("`\`(")) {
        $det = $det.Replace("`\`(", "`(")
        }
    if ($det.Contains("`\`)")) {
        $det = $det.Replace("`\`)", "`)")
        }
    return $det
    }

function word_close ($mydoc) {
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
    $lastitem = ""
    $curIssue = @{}
    $mIssue = @{}
    $lastiss = ""
    $port = ""
    $ports = ""
    $protocol = ""
    $details = ""
    $detail = ""
    $evidences = ""
    $evidence = ""
    foreach ($line in $csvfile) {
        if ($fps -eq 1) {
            $fps = 0
            $curblock += $line
            $lastln = $line
            }
        else {
            #if ($line."Asset IP Address" -eq "end") {continue}
            if ($line."Asset IP Address" -eq $lastln."Asset IP Address") {
                $curblock += $line
                $lastln = $line
                }
            elseif ($line."Asset IP Address" -ne $lastln."Asset IP Address") {
                $fsps = 1
                $fcp = 1
                $fpp = 1
                $blocknt = 0
                foreach ($item in $curblock) {
                    $blocknt += 1
                    $curIssue = read_line $item
                    if ($fsps -eq 1) {
                        $fsps = 0
                        $lastiss = $curIssue.Get_Item("issue")
                        }
                                        
                    elseif ($item."Vulnerability Title" -ne $mIssue.Get_Item("issue")) {
                        $tissue = $mIssue.Get_Item("issue")
                        if ($mIssue.Get_Item("type") -eq "confirmed" -and $fcp -eq 1) {
                            $fcp = 0
                            $mysel.InsertBreak(7)
                            #$mysel.Range.Font.Bold = 1
                            $hip = $mIssue.Get_Item("hostIP")
                            $mysel.typeText("$hip Confirmed Vulnerabilities")
                            $mysel.Style = "Heading 4"
                            $mysel.TypeParagraph()
                            }
                        elseif ($mIssue.Get_Item("type") -eq "potential" -and $fpp -eq 1) {
                            $fpp = 0
                            if ($fcp -eq 1) {
                                $mysel.InsertBreak(7)
                                }
                            #$mysel.Range.Font.Bold = 1
                            $hip = $mIssue.Get_Item("hostIP")
                            $mysel.typeText("$hip Potential Vulnerabilities")
                            $mysel.Style = "Heading 4"
                            $mysel.TypeParagraph()
                            }
                        elseif ($mIssue.Get_Item("type") -eq "accepted" -and $fpp -eq 1) {
                            $fpp = 0
                            if ($fcp -eq 1) {
                                $mysel.InsertBreak(7)
                                }
                            #$mysel.Range.Font.Bold = 1
                            $hip = $mIssue.Get_Item("hostIP")
                            $mysel.typeText("$hip Accepted Vulnerabilities")
                            $mysel.Style = "Heading 4"
                            $mysel.TypeParagraph()
                            }
                        $details = <#clean_info#> $details
                        $evidences = clean_info $evidences
                        $mIssue.Set_Item("port", $ports)
                        $tdetails = $details
                        $tdetails += "Evidence, Location, or Additional Information:`n"+$evidences
                        $mIssue.Set_Item("detail", $tdetails)
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
                        $lastiss = $mIssue.Get_Item("issue")
                        $mIssue = @{}
                        $port = ""
                        $ports = ""
                        $protocol = ""
                        $details = ""
                        $tdetails = ""
                        $evidences = ""
                        }

                    $mIssue = $curIssue
                    $port = $mIssue.Get_Item("port")
                    $protocol = $mIssue.Get_Item("protocol")
                    $details = <#info_clean#> $mIssue.Get_Item("detail")
                    $evidence =  info_clean $mIssue.Get_Item("evidence")

                    if ($port -eq "0" -or $port -eq '') {
                        $ports = "N/A"
                        }
                    elseif ($ports -notmatch "$port/$protocol") {
                        if ($ports -ne "") {
                            $ports += "`n$port/$protocol"
                            }
                        else {
                            $ports += "$port/$protocol"
                            }
                        }
                    if ($evidences -notmatch $evidence) {
                        if ($evidences -ne "") {
                            $evidences += "`n$evidence"
                            }
                        else {
                            $evidences += $evidence
                            }
                        }
                    if ($blocknt -ge $curblock.Count) {
                        if ($mIssue.Get_Item("type") -eq "confirmed" -and $fcp -eq 1) {
                            $fcp = 0
                            $mysel.InsertBreak(7)
                            #$mysel.Range.Font.Bold = 1
                            $hip = $mIssue.Get_Item("hostIP")
                            $mysel.typeText("$hip Confirmed Vulnerabilities")
                            $mysel.Style = "Heading 4"
                            $mysel.TypeParagraph()
                            }
                        elseif ($mIssue.Get_Item("type") -eq "potential" -and $fpp -eq 1) {
                            $fpp = 0
                            if ($fcp -eq 1) {
                                $mysel.InsertBreak(7)
                                }
                            #$mysel.Range.Font.Bold = 1
                            $hip = $mIssue.Get_Item("hostIP")
                            $mysel.typeText("$hip Potential Vulnerabilities")
                            $mysel.Style = "Heading 4"
                            $mysel.TypeParagraph()
                            }
                        $details = <#clean_info#> $details
                        $evidences = clean_info $evidences
                        $mIssue.Set_Item("port", $ports)
                        $tdetails = $details
                        $tdetails += "Evidence, Location, or Additional Information:`n"+$evidences
                        $mIssue.Set_Item("detail", $tdetails)
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
                        $lastiss = $mIssue.Get_Item("issue")
                        $mIssue = @{}
                        $details = ""
                        $tdetails = ""
                        $port = ""
                        $ports = ""
                        $protocol = ""
                        $evidences = ""
                        }
                    }
                $curblock = @()
                $curblock += $line
                $lastln = $line
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
    $fps = 1
    foreach ($line in $csvfile) {
        $curitem = read_line $line
        #if ($curitem.Get_item('hostIP') -eq "end") {continue}
        if ($curitem.Get_item('type') -ne $mtype -and $fps -eq 1) {
            $mtype = $curitem.Get_item('type')
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
            $mIssue = @{}
            $details = $lastitem.Get_Item("detail")
            $issue = $lastitem.Get_item("issue")
            $finding = $lastitem.Get_Item("finding")
            $solution = $lastitem.Get_Item("solution")
            $ref = $lastitem.Get_Item("ref")
            $rating = $lastitem.Get_Item("rating")
            $thost = ""
            $evidences = ""
            foreach ($item in $curblock) {
                $hostport = ''
                $port = $item.Get_Item("port")
                $protocol = $item.Get_Item("protocol")
                $hip = $item.Get_Item("hostIP")
                if ($port -eq "0" -or $port -eq '') {
                    $ports = "N/A"
                    }
                else {
                    $ports = "$port/$protocol"
                    }
                $hostport = $hip+":"+$ports
                if ($thost -notmatch $hostport) {
                    $thost += $hostport+"`n"
                    }
                $evidence =  info_clean $item.Get_Item("evidence")
                #if ($evidences -notmatch $evidence) {
                    if ($evidences -ne "") {
                        $evidences += "`n"+$hostport+" -:-`n$evidence"
                        }
                    else {
                        $evidences += $hostport+" -:-`n$evidence"
                        }
                    #}
                }
            $tdetails = $details
            $evidences = clean_info $evidences
            $tdetails += "Evidence, Location, or Additional Information:`n"+$evidences
            $mIssue.Set_Item("issue", $issue)
            $mIssue.Set_Item("finding", $finding)
            $mIssue.Set_Item("rating", $rating)
            $mIssue.Set_Item("detail", $tdetails)
            $mIssue.Set_Item("hostIP", $thost)
            $mIssue.Set_Item("solution", $solution)
            $mIssue.Set_Item("ref", $ref)
            $mIssue.Set_Item("type", $lastitem.Get_Item("type"))

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
$starttime = Get-Date

$file = Get-FileName "Open the nexpose_csv file"
$msaveloc = Get-FolderName "Select the folder where you want to save the tables"

$tempfilenamebase = "$msaveloc\" + (Get-Date).ToString('M-d-y')

$gtype = 0
while ($gtype -ne 1 -and $gtype -ne 2) {
    $gtype = Read-Host "`nPlease select a Grouping Type:`n1) By Host (Bronze-Platinum)`n2) By Vulnerability (Titanium-Pen Test)`n(-"
    }

$myword = New-Object -ComObject word.application
$myword.Visible = $false
$wsc = $myword.Options.CheckSpellingAsYouType
$wgc = $myword.Options.CheckGrammarAsYouType
$myword.Options.CheckSpellingAsYouType = $false
$myword.Options.CheckGrammarAsYouType = $false

$mydoc, $mysel = word_start $myword

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
$tempfilename = $tempfilenamebase + "_" + $filenum + " nexpose-tables.docx"
$mydoc.SaveAs([REF]$tempfilename)
Write-Debug "SAVED"
$myword.Options.CheckSpellingAsYouType = $wsc
$myword.Options.CheckGrammarAsYouType = $wgc
$myword.Visible = $true

$endtime = Get-Date
$lentime = $endtime - $starttime
#Write-Host $lentime
}