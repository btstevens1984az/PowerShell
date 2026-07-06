Function Scan-DomainWithVirusTotal {
<#
.SYNOPSIS
    Just a simple PowerShell script to automate the retrieval or scanning of URLs.
.DESCRIPTION
    Queries Virus Total and retrieves scan data
    Maliicous positives
    Scan date
    Permalink to scan report
    Submits a URL to be scanned if it's not in the dataset
    Displays script progress and results per URL
    Displays tables of malicious URLs and URLs where no scan report was found
    Exports scan data to CSV
    Malicious positives
    URL
    Scan date
    Permalink to scan report
    Estimates time to completion, and calculates time taken when complete
.INSTRUCTIONS
    Please sign in to https://www.virustotal.com/en/ and retrieve API Key from profile created 
    Place in PowerShell function Scan-DomainWithVirusTotal line 11
    File Name      : Scan-DomainWithVirusTotal.ps1
    Prerequisite   : PowerShell V2
    Copyright 2018 - Brandon Stevens
.LINK
    https://www.virustotal.com/en/
.EXAMPLE
    PS C:\Windows\system32>Scan-DomainWithVirusTotal  **Press Enter**
    --- Virus Total URL Query ---

    Info: Due to restrictions for public API use, 
    Info: there is a 26 second pause between queries.

    ================================

    Domains: 3
    Estimated time: 00:00:52

    Querying...
    --------------------------------
    1/3 :: google.com ... Malicious 1/67
    2/3 :: whitehouse.gov ... Clean
    3/3 :: whitehouse.com ... Clean

    ================================

    --- Results ---

    Positive malicious hits: 1
#>
$cnt = 0
$input_file = "C:\Users\'$env:USERNAME'\PowerShell\Files\Domains.txt"
# $api_key_file = Get-Content .\api_key.txt | Out-String | ConvertFrom-StringData
$api_key = "56067413e1905f235052063b7d83872da8c21f27088495bf5b29edc81d3355d3" # $api_key_file.api_key
$mal_hits = 0
$mal_urls = [ordered]@{}
$start = 0
$stop = 0
 
function pause {
    Read-Host "`n`nPress Enter to continue." | Out-Null
}
 
function check_api_key {
    # $api_check = Get-Content .\api_key.txt | Out-String | ConvertFrom-StringData
    If (-not $api_key) {
        Write-Host "`n`n*** Virus Total API key not present in the api_key variable. ***" -ForegroundColor Yellow
        pause
        Break
    }
}
 
function welcome {
    Write-Host "`n`n--- Virus Total URL Query ---"
    Write-Host "`nInfo: Due to restrictions for public API use, `nInfo: there is a 26 second pause between queries.`n"
    Write-Host "================================`n"
}
 
function vt_search {
    $Global:start = Get-Date
    $estimate_time = $start + (New-TimeSpan -Seconds (((Get-Content $input_file | Measure-Object -Line).Lines - 1) * 26))
    $estimate_elapsed = $estimate_time - $start
    
    Write-Host "Domains:" (Get-Content $input_file | Measure-Object -Line).Lines
    Write-Host "Estimated time: $estimate_elapsed`n"
    Write-Host "Querying...`n--------------------------------"
    
    Get-Content $input_file | ForEach-Object {
        $cnt += 1
        $totalLines = (Get-Content $input_file | Measure-Object -Line).Lines
        
        Write-Host "$cnt/$totalLines :: $_" -NoNewline
 
        $url = "http://www.virustotal.com/vtapi/v2/url/report?apikey=" + $api_key + "&resource=" + $_
 
        $query = Invoke-RestMethod -Method "POST" -Uri $url
         
        If ($query.response_code -eq 0) {
            Write-Host "... No report. Scanning" -NoNewLine
            $query = vt_scan $_
        }
 
        If ($query.positives -gt 0) {
            $Global:mal_hits += 1
            $mal_urls[$query.url] = [ordered]@{"url"=$query.url; "hits"=$query.positives; "scan_date"=$query.scan_date; "permalink"=$query.permalink}
            Write-Host (" ... Malicious {0}/{1}" -f $query.positives, $query.total) -ForegroundColor Red
        } ELSEIF (-not $query.response_code -eq 1) {
            $mal_urls[$query.resource] = [ordered]@{"url"=$query.resource; "hits"=$null; "scan_date"="No scan report"; "permalink"="Perform manual scan of URL";}
            Write-Host (" ... No scan report") -ForegroundColor Yellow
        } ELSE {
            Write-Host " ... Clean"
        }
        
        If ($cnt -lt $totalLines) {
            Start-Sleep -Seconds 26
        }
    }
}
 
function vt_scan($scan_url){
    $url = "https://www.virustotal.com/vtapi/v2/url/scan?apikey=" + $api_key + "&url=" + $scan_url
    return Invoke-RestMethod -Method Post -Uri $url
}
 
function show_results {
    $Global:stop = Get-Date
    
    Write-Host "`n================================"
    Write-Host "`n--- Results ---"
    Write-Host "`nPositive malicious hits: " -NoNewLine
    
    If ($Global:mal_hits -gt 0) {
        Write-Host "$Global:mal_hits" -ForegroundColor Red
    } Else {
        Write-Host "$Global:mal_hits" -ForegroundColor Green
    }
   
    Write-Host "`n--------------------------------`n"
    Write-Host "List of malicious URLs:"
    Write-Host "`nHits `t URL`n--- `t ---"
    
    ForEach ($k in $mal_urls.Keys) {
        If ($mal_urls.$k.hits -gt 0) {
            Write-Host $mal_urls.$k.hits `t $k
        }
    }
    
    Write-Host "`n--------------------------------"
    Write-Host "`nList of URLS without scan reports"
    Write-Host "`nURL `n---"
    
    ForEach ($k in $mal_urls.Keys) {
        If ($mal_urls.$k.scan_date -eq "No scan report") {
            Write-Host $mal_urls.$k.url
        }
    }
    
    Write-Host "`n================================`n"
}
 
function save_file {
    $date = Get-Date -UFormat %Y.%m.%d
    $time = Get-Date -UFormat %H.%M.%S
    $elapsed = $Global:stop - $Global:start
    
    Write-Host "--- Export Results ----"
    Write-Host ("`n`Saving malicous urls to $date`_$time`_malicious_urls.csv")
    
    ForEach ($k in $mal_urls.Keys) {
        New-Object -typename psobject -property $mal_urls.$k | Select hits,url,scan_date,permalink | Export-Csv -Path "C:\Users\'$env:USERNAME'\PowerShell\Files\$date`_$time`_VirusTotalResults.csv" -NoTypeInformation -Append
    }
    
    Write-Host "`n`n--------------------------------"
    
    Write-Host ("`nStart: $Global:start `t Stop: $Global:stop `nElapsed: $elapsed")
}

}
