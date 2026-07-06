WorkFlow Start-Rapid7Scan {

<# 
.SYNOPSIS 
    This is an example Powershell Workflow for adding a host to the Nexpose Rapid7 Security Scanner, 
    initiating a baseline scan and then emailing the results to a user. 
    Workflow utilizes the Nexpose XML API. 
 
.DESCRIPTION 
 
.PARAMETER ComputerName 
 
.PARAMETER ErrorLog 
 
.EXAMPLE
 
.EXAMPLE 

.EXAMPLE 

.LINK 

    Date:    29APR2018 
    PSVer:   3.0/4.0/5.0 
#> 
    param(

        [Parameter(Mandatory = $true)]
        [string]
        $server_name,

        [Parameter(Mandatory = $true)]
        [string]
        $production_status,

        [Parameter(Mandatory = $true)]
        [string]
        $build_admin

    )
    
    # get SMA assets
    $credentials = Get-AutomationPSCredential -name ''
    $Rapid7_Prod_Site = Get-AutomationVariable -Name 'Rapid7_PROD_Site'
    $Rapid7_DEVQA_Site = Get-AutomationVariable -Name 'Rapid7_QA_Site'
    $Day = (Get-Date).Day
    $Month = (Get-Date).Month
    $Year = (Get-Date).Year
    $FormattedDate = Write-Host "$Month/$Day/$Year"

    $output = InlineScript {

        $creds = $using:credentials
        $user = $creds.UserName.replace("AD_DOMAIN\","")
        $password = $creds.GetNetworkCredential().password
        
        $api = "1.1"
        $uri = "https://rapid7.example.com:3780/api/$api/xml"
        $template_id = "my_template"
        $sync_id = Get-Random

        if ($using:production_status -eq "Production") 
        {
            $site_name = $using:Rapid7_Prod_Site
        } 
        else
        {
            $site_name = $using:Rapid7_DEVQA_Site
        }

# ignore certificate errors
Add-Type @"
        using System.Net;
        using System.Security.Cryptography.X509Certificates;
        public class TrustAllCertsPolicy : ICertificatePolicy {
            public bool CheckValidationResult(
                ServicePoint srvPoint, X509Certificate certificate,
                WebRequest request, int certificateProblem) {
                return true;
            }
        }
"@

        [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

        # log into nexpose api
        $login = "<LoginRequest user-id='$user' password='$password' />"
        $login_response = Invoke-WebRequest -URI $uri -Body $login -ContentType 'text/xml' -Method post
        $session_id = $login_response.Content | select-xml -XPath '//LoginResponse' | % {$_.node.'session-id'}

        if ($session_id -eq $null) 
        {  
            return @{ "error" = "Error logging into the Nexpose API" }
        }

        # get our site id
        $get_site_listing = "<SiteListingRequest session-id='$session_id' sync-id='$sync_id'/>"
        $response_site_listing = Invoke-WebRequest -URI $uri -Body $get_site_listing -ContentType 'text/xml' -Method post
        [xml]$xml_string = $response_site_listing.Content
        $site_id = $xml_string.SiteListingResponse.SiteSummary | ? {$_.name -eq $site_name} | % {$_.id}

        # check to see if the site is already running an ad-hoc scan before attempting to save config
        # since config cannot be modified while a scan is running

        $scan_activity_request = "<ScanActivityRequest session-id='$session_id'/>"
        $response_scan_activity = Invoke-WebRequest -URI $uri -Body $scan_activity_request -ContentType 'text/xml' -Method post
        $scan_activity = $response_scan_Activity | select-xml -XPath '//ScanSummary' | ? {$_.node.'site-id' -eq $site_id } | % {$_.node.'status'}

        if ($scan_activity -eq "running") {

            do {

                $response_scan_activity = Invoke-WebRequest -URI $uri -Body $scan_activity_request -ContentType 'text/xml' -Method post
                $scan_activity = $response_scan_Activity | select-xml -XPath '//ScanSummary' | ? {$_.node.'site-id' -eq $site_id } | % {$_.node.'status'}

                Start-Sleep -Seconds 60

            } until ($scan_activity -ne "running")

        }

        # create new site config with new host. We do this by downloading the current site config, appending our new host
        # to the list of site hosts, then saving the new config

        $get_site_config = "<SiteConfigRequest session-id='$session_id' site-id='$site_id' sync-id='$sync_id'/>"
        $response_config = Invoke-WebRequest -URI $uri -Body $get_site_config -ContentType 'text/xml' -Method post
        [xml]$site_config = $response_config.Content

        $new_element = $site_config.CreateElement("host")
        $new_element = $site_config.SiteConfigResponse.Site.Hosts.AppendChild($new_element)
        $new_element.InnerText = "$using:server_name"

        $new_site_config = $site_config.OuterXml
        $new_site_config = $new_site_config.Replace('<SiteConfigResponse success="1">',"<SiteSaveRequest session-id='$session_id'>")
        $new_site_config = $new_site_config.Replace("</SiteConfigResponse>","</SiteSaveRequest>")

        $response_save = Invoke-WebRequest -URI $uri -Body $new_site_config -ContentType 'text/xml' -Method post

# start a new scan on our host
$site_device_scan = @"
                    <SiteDevicesScanRequest session-id='$session_id' sync-id ='$sync_id' site-id='$site_id'>
                        <hosts>
                            <host>$using:server_name</host>
                        </hosts>
                    </SiteDevicesScanRequest>
"@

        # get scan id
        $response_device_scan = Invoke-WebRequest -URI $uri -Body $site_device_scan -ContentType 'text/xml' -Method post
        $scan_id = $response_device_scan | select-xml -XPath '//Scan' | % {$_.node.'scan-id'}

        # get scan status and then montior it until it's finished
        $scan_status_request = "<ScanStatusRequest session-id='$session_id' scan-id='$scan_id' />"

        $counter = 0

        do {
    
            $response_scan_status = Invoke-WebRequest -URI $uri -Body $scan_status_request -ContentType 'text/xml' -Method post
            $scan_status = $response_scan_status | select-xml -XPath '//ScanStatusResponse' | % {$_.node.'status'}

            Start-Sleep -Seconds 60

            $counter++

            if ($counter -eq 60) 
            { 
                return @{ "error" =  "Could not find Nexpose scan for host" }
            }

        } until ($scan_status -eq "finished") 

        # get a list of all device ids in our site
        $site_device_listing = "<SiteDeviceListingRequest session-id='$session_id' sync-id='$sync_id' site-id='$site_id'/>"
        $response_site_device_listing = Invoke-WebRequest -URI $uri -Body $site_device_listing -ContentType 'text/xml' -Method post

        # get host ipaddress from DNS
        $ip_address = [System.Net.Dns]::GetHostAddresses($using:server_name) | % {$_.ipaddresstoString}

        # get device id from xml by searching for device by ip address
        [xml]$xml_string = $response_site_device_listing.Content
        $device_id = $xml_string.SiteDeviceListingResponse.SiteDevices.device | ? {$_.address -eq $ip_address} | % {$_.id} | Sort-Object -Descending | Select-Object -First 1

# now we generate an adhoc report for the last scan using our device id
$adhoc_generate_report_request = @"
    <ReportAdhocGenerateRequest session-id='$session_id' sync-id='$sync_id'> 
        <AdhocReportConfig format="csv" template-id='$template_id'>
            <Filters>
                <filter type="device" id='$device_id'/>
                <filter type="scan" id="last" />
                <filter type="vuln-status" id="vulnerable-exploited" />
                <filter type="vuln-status" id="vulnerable-version" />
                <filter type="vuln-status" id="potential" />
            </Filters>
    </AdhocReportConfig>
</ReportAdhocGenerateRequest>
"@

        try {

        $response_generate_adhoc_report = Invoke-WebRequest -URI $uri -Body $adhoc_generate_report_request -ContentType 'text/xml' -Method post

        # grab mime message from response and decode into utf8 text
        $content = [System.Text.Encoding]::UTF8.GetString($response_generate_adhoc_report.Content)
        $content | out-file $pwd\temp.txt
        $content = get-content $pwd\temp.txt
                remove-item $pwd\temp.txt

        $extracted_mime_content = $null

        for($index = 8; $index -lt ($content.Length - 2);$index++) {
    
            $extracted_mime_content += $content[$index]
        }

        $bytes = [System.Convert]::FromBase64String($extracted_mime_content)
        $extracted_mime_content= [System.Text.Encoding]::UTF8.GetString($bytes)
        $extracted_mime_content | out-file $pwd\temp_report.csv
        $vulns = import-csv $pwd\temp_report.csv
        remove-item $pwd\temp_report.csv

        # format and edit report
        $vulns = $vulns | Sort-Object -Property 'Vulnerability Title' -Unique

        $vulns  | % {

            $vuln_level = [convert]::ToInt32($_.'Vulnerability Severity Level')
   
            if ($vuln_level -ge 8) {
      
                $_.'Vulnerability Severity Level' = "Critical"
    
            } elseif ($vuln_level -ge 4) {
    
                $_.'Vulnerability Severity Level' = "Moderate"
        
            } else {
    
                $_.'Vulnerability Severity Level' = "Low"
    
            }

        }

        # convert report to html
        [string]$html = $vulns | ConvertTo-Html

        } catch {

            return @{ "error" =  "Error encountered generating report" }
        }

        # log out of Nexpose api

        $logout = "<LogoutRequest session-id='$session_id' />"
        $logout_response = Invoke-WebRequest -URI $uri -Body $logout -ContentType 'text/xml' -Method post

        # send report to the build admin

    }

    if ($output.error)
    {

    }

}