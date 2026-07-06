# Purpose: Merge-CSV — Reusable PowerShell function libraries.
Function Merge-CSV {

    [CmdletBinding()]
    param (
        # Path to first .csv file
        [parameter(Mandatory=$True)]
        [string]$CSVPath1,

        # Path to second .csv file
        [parameter(Mandatory=$True)]
        [string]$CSVPath2,

        # Column header to merge on in $CSVPath1
        [parameter(Mandatory=$True)]
        [string]$CSVMergeKey1,
        
        # Column header to merge on in $CSVPath2
        [parameter(Mandatory=$True)]
        [string]$CSVMergeKey2,
        
        # Path to output the merged .csv file
        [parameter(Mandatory=$True)]
        [string]$OutPath
    )

    # Import .csv files to be merged
    $CSVImport_1 = Import-Csv -Path $CSVPath1
    $CSVImport_2 = Import-Csv -Path $CSVPath2

    # Convert $CSVMergeKey2 to $CSVMergeKey1
    if ($CSVMergeKey1 -ne $CSVMergeKey2) {
        $CSVImport_2 = $CSVImport_2 |select @{N=$CSVMergeKey1; E={$_.$CSVMergeKey2}}, * -ExcludeProperty $CSVMergeKey2
    }
    
    # Build list of CSV field headers
    [System.Collections.ArrayList]$CSVFieldList_1 = $CSVImport_1 |`
        gm -MemberType NoteProperty |select -ExpandProperty Name
    [System.Collections.ArrayList]$CSVFieldList_2 = $CSVImport_2 |`
        gm -MemberType NoteProperty |select -ExpandProperty Name 
    
    $CSVFieldList_2.Remove($CSVMergeKey1)
    
    # Collect list of duplicate keys
    [System.Collections.ArrayList]$CSVFieldListDupes = foreach($key in $CSVFieldList_1) {
        if($key -in $CSVFieldList_2) { 
            $key 
        } 
    }
    
    #If duplicate fields exist that are not the Merge Key modify duplicates in 2nd csv
    if ($CSVFieldListDupes.Count -gt 0) {
        foreach($dupe in $CSVFieldListDupes) {
            $CSVImport_2 = $CSVImport_2 |select @{N=$dupe+"2"; E={$_.$dupe}}, * -ExcludeProperty $dupe
            $CSVFieldList_2 = $CSVFieldList_2.replace($dupe,$dupe+"2")
        }
    }

    # Collect unique merge values
    [System.Collections.ArrayList]$uniqueKeyValues = $CSVImport_1.$CSVMergeKey1 + $CSVImport_2.$CSVMergeKey1 |sort -Unique

    # Collect unique header values
    [System.Collections.ArrayList]$CSVFieldList_ALL = $CSVFieldList_1 + $CSVFieldList_2

    #region Build hashtable with all unique Merge values and empty fields
    [System.Collections.ArrayList]$AllHashList = @()

    foreach ($value in $uniqueKeyValues) {
        [System.Collections.Hashtable]$HashStore = @{}
        foreach ($field in $CSVFieldList_ALL) {
            $HashStore.Add("$field",'')
        }
        $HashStore.$CSVMergeKey1 = $value
        $AllHashList += $HashStore
    }

    # Remove MergeField from FieldList 
    $CSVFieldList_ALL.Remove($CSVMergeKey1)

    # Update hashtable with data from imported csv files
    foreach ($table in $AllHashList){
        foreach ($value in $CSVFieldList_ALL) {
            if ($table.$CSVMergeKey1 -in $CSVImport_1.$CSVMergeKey1 -and $value -in $CSVFieldList_1) {
                $table.$value = $($CSVImport_1 |where {$_.$CSVMergeKey1 -eq $table.$CSVMergeKey1} |`
                                select -ExpandProperty $value)
            }
            elseif ($table.$CSVMergeKey1 -in $CSVImport_2.$CSVMergeKey1 -and $value -in $CSVFieldList_2 -or $value -eq $CSVMergeKey1) {
                $table.$value = $($CSVImport_2 |where {$_.$CSVMergeKey1 -eq $table.$CSVMergeKey1} |`
                                select -ExpandProperty $value)
            }
            else {
                $table.$value = ''
            }
        }
    }

    # Perform readability formatting on hashtables prior to exporting
    foreach ($table in $AllHashList) {
        foreach ($key in $($table.keys)) {
            $table.$key = $table.$key |select -Unique
            $table.$key = $table.$key -join "`r`n"
        }
    }

    # Export final results
    $AllHashList |ForEach-Object {[PSCustomObject]$_ }|Export-Csv -Path $OutPath -NoTypeInformation
}

#Install-Module -Name "ImportExcel"
#Import-Module -Name "ImportExcel"
#Import-Csv -Path 'C:\Users\Qwerty\Desktop\Nexpose\Post-Scan - Patchfest Reboot Group 1000 - Tuesday, May, 22, 2018 13001.csv' `
#| Select-Object -Property "Asset IP Address","Vulnerability Severity Level","Vulnerability CVE IDs","Asset Risk Score","Vulnerability Risk Score" `
#| Format-Table -AutoSize -Wrap
#Merge-CSV -CSVPath1 'C:\Users\Qwerty\Desktop\Pre-Scan - Patchfest Reboot Group 1000 - Tuesday, May, 22, 2018 13001.csv' -CSVPath2 'C:\Users\Qwerty\Desktop\Post-Scan - Patchfest Reboot Group 1000 - Tuesday, May, 22, 2018 13001.csv' -CSVMergeKey1 "Asset IP Address" -CSVMergeKey2 "Asset IP Address" -OutPath 'C:\Users\Qwerty\Desktop\Nexpose\MergedNexposeReport.csv'
#Import-Csv -Path 'C:\Users\Qwerty\Desktop\Nexpose\MergedNexposeReport.csv' | Select-Object -Property "Asset IP Address","Asset Names","Asset Names2","OS Version","OS Version2","OS Name","OS Name2","Vulnerability Risk Score","Vulnerability Risk Score2","Vulnerability Test Result Description","Vulnerability Test Result Description2","Risk Score","Risk Score2","Vulnerability Proof","Vulnerability Proof2","Vulnerability Severity Level","Vulnerability Severity Level2","Vulnerability CVE IDs","Vulnerability CVE IDs2","Vulnerability CVE URLs","Vulnerability CVE URLs2","Vulnerability Title","Vulnerability Title2","Service Port","Service Port2","Vulnerability Tags","Vulnerability Tags2","Vulnerability Reference URLs","Vulnerability Reference URLs2","Vulnerability Additional URLs","Vulnerability Additional URLs2","Vulnerability Reference IDs","Vulnerability Reference IDs2","Vulnerability Description","Vulnerability Description2" | Export-Csv "C:\Users\Qwerty\Desktop\Nexpose\Nexpose Patchfest Report.csv" -NoTypeInformation -Force -Delimiter "`t"
#Start-Sleep -Seconds 5
#Remove-Item -Path "C:\Users\Qwerty\Desktop\Nexpose\MergedNexposeReport.csv" -Force
#$CSVREPORTFINAL = Import-CSV "C:\Users\Qwerty\Desktop\Nexpose\Nexpose Patchfest Report.csv" -Encoding ASCII
#$ColumnsCSVReports = Import-Csv -Header ("AssetIPAddress","AssetNames","AssetNames2","OSVersion","OSVersion2","OSName","OSName2","VulnerabilityRiskScore","VulnerabilityRiskScore2","VulnerabilityTestResultDescription","VulnerabilityTestResultDescription2","VulnerabilityProof","VulnerabilityProof2","VulnerabilitySeverityLevel","VulnerabilitySeverityLevel2","VulnerabilityCVEIDs","VulnerabilityCVEIDs2","VulnerabilityCVEURLs","VulnerabilityCVEURLs2","VulnerabilityTitle","VulnerabilityTitle2","ServicePort","ServicePort2","VulnerabilityTags","VulnerabilityTags2","VulnerabilityReferenceURLs","VulnerabilityReferenceURLs2","VulnerabilityAdditionalURLs","VulnerabilityAdditionalURLs2","VulnerabilityReferenceIDs","VulnerabilityReferenceIDs2","VulnerabilityDescription","VulnerabilityDescription2") -Path "C:\Users\Qwerty\Desktop\Nexpose\Create-NexposeReport.ps1"
#foreach ($ColumnsCSVReport in $ColumnsCSVReports) {
#$AssetIPAddress=$ColumnsCSVReport.AssetIPAddress
#$AssetNames=$ColumnsCSVReport.AssetNames
#$AssetNames2=$ColumnsCSVReport.AssetNames2
#$OSVersion=$ColumnsCSVReport.OSVersion
#$OSVersion2=$ColumnsCSVReport.OSVersion2
#$OSName=$ColumnsCSVReport.OSName
#$OSName2=$ColumnsCSVReport.OSName2
#$VulnerabilityRiskScore=$ColumnsCSVReport.VulnerabilityRiskScore
#$VulnerabilityRiskScore2=$ColumnsCSVReport.VulnerabilityRiskScore2
#$VulnerabilityTestResultDescription=$ColumnsCSVReport.VulnerabilityTestResultDescription
#$VulnerabilityTestResultDescription2=$ColumnsCSVReport.VulnerabilityTestResultDescription2
#$RiskScore=$ColumnsCSVReport.RiskScore
#$RiskScore2=$ColumnsCSVReport.RiskScore2
#$VulnerabilityProof=$ColumnsCSVReport.VulnerabilityProof
#$VulnerabilityProof2=$ColumnsCSVReport.VulnerabilityProof2
#$VulnerabilitySeverityLevel=$ColumnsCSVReport.VulnerabilitySeverityLevel
#$VulnerabilitySeverityLevel2=$ColumnsCSVReport.VulnerabilitySeverityLevel2
#$VulnerabilityCVEIDs=$ColumnsCSVReport.VulnerabilityCVEIDs
#$VulnerabilityCVEIDs2=$ColumnsCSVReport.VulnerabilityCVEIDs2
#$VulnerabilityCVEURLs=$ColumnsCSVReport.VulnerabilityCVEURLs
#$VulnerabilityCVEURLs2=$ColumnsCSVReport.VulnerabilityCVEURLs2
#$=$ColumnsCSVReport.VulnerabilityTitle
#$VulnerabilityTitle2=$ColumnsCSVReport.VulnerabilityTitle2
#$ServicePort=$ColumnsCSVReport.ServicePort
#$ServicePort2=$ColumnsCSVReport.ServicePort2
#$VulnerabilityTags=$ColumnsCSVReport.VulnerabilityTags
#$VulnerabilityTags2=$ColumnsCSVReport.VulnerabilityTags2
#$VulnerabilityReferenceURLs=$ColumnsCSVReport.VulnerabilityReferenceURLs
#$VulnerabilityReferenceURLs2=$ColumnsCSVReport.VulnerabilityReferenceURLs2
#$VulnerabilityReferenceIDs=$ColumnsCSVReport.VulnerabilityReferenceIDs
#$VulnerabilityReferenceIDs2=$ColumnsCSVReport.VulnerabilityReferenceIDs2
#$VulnerabilityDescription=$ColumnsCSVReport.VulnerabilityDescription
#$VulnerabilityDescription2=$ColumnsCSVReport.VulnerabilityDescription2
#  }
#
#
#
#$head = @'
#<style>
#body { background-color:#dddddd;
#       font-family:Tahoma;
#       font-size:12pt; }
#td, th { border:1px solid black;
#         border-collapse:collapse; }
#th { color:white;
#     background-color:black; }
#table, tr, td, th { padding: 2px; margin: 0px }
#table { margin-left:50px; }
#</style>
#'@
#$Reportheaders = "Asset IP Address","Asset Names","Asset Names2","OS Version","OS Version2","OS Name","OS Name2","Vulnerability Risk Score","Vulnerability Risk Score2","Vulnerability Test Result Description","Vulnerability Test Result Description2","Risk Score","Risk Score2","Vulnerability Proof","Vulnerability Proof2","Vulnerability Severity Level","Vulnerability Severity Level2","Vulnerability CVE IDs","Vulnerability CVE IDs2","Vulnerability CVE URLs","Vulnerability CVE URLs2","Vulnerability Title","Vulnerability Title2","Service Port","Service Port2","Vulnerability Tags","Vulnerability Tags2","Vulnerability Reference IDs","Vulnerability Reference IDs2","Vulnerability Description","Vulnerability Description2"
#$CSVREPORTFINAL | Select $Reportheaders | ConvertTo-html -Body "<H2> Data from Pre and Post Patch Reports $(Date)</H2>" -Title "Patchfest Nexpose Report $(Date)" -Head $head -As Table -Property $Reportheaders -Post "<h1>PATCH NEXPOSE REPORT BRANDON STEVENS</h1>" >> "C:\Users\Qwerty\Desktop\Nexpose\NexposeReport.html"
