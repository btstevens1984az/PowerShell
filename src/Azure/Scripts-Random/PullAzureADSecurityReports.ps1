# Purpose: PullAzureADSecurityReports — Microsoft Azure cloud resource management.
#************************************************
# PullAzureSecurityReports.ps1
# Version 1.0
# Date: 10-31-2016
# Description: This script will search an Azure AD tenant which has Azure AD Premium and pull the 
#  Security related reports using GraphApi for audit results for a specified period till current time. 
#  At least one user must be assigned an AAD Premium license for this to work.
# Results are placed into CSV files for each report type for review.
#************************************************
cls

# This script will require the Web Application and permissions setup in Azure Active Directory
$ClientID       = "your-application-client-id-here"             # Should be a ~35 character string insert your info here
$ClientSecret   = "your-application-client-secret-here"         # Should be a ~44 character string insert your info here
$loginURL       = "https://login.windows.net"
$tenantdomain   = "your-directory-name-here.onmicrosoft.com"            # For example, contoso.onmicrosoft.com

$AuditOutput = $Pwd.Path + "\" + (($tenantname.Split('.')[0]) + "_AuditReport.csv")
$Tenantname = $tenantdomain.Split('.')[0]
Write-Host "Collecting Azure AD security reports for tenant $tenantdomain`."

function GetReport      ($url, $reportname, $tenantname) {
$AuditOutputCSV = $Pwd.Path + "\" + (($tenantname.Split('.')[0]) + "_AuditReport.csv")
# Get an Oauth 2 access token based on client id, secret and tenant domain
$loginURLL = "https://login.microsoft.com"
$resource = "https://graph.microsoft.com"
$body       = @{grant_type="client_credentials";resource=$resource;client_id=$ClientID;client_secret=$ClientSecret}
$oauth      = Invoke-RestMethod -Method Post -Uri $loginURL/$tenantname/oauth2/token?api-version=1.0 -Body $body
$AuditOutputCSV = $Pwd.Path + "\" + $tenantname + "_$reportname.csv"
Write-Host "Collecting Azure AD security report "  $reportname "..."
if ($oauth.access_token -ne $null) {
    $headerParams = @{'Authorization'="$($oauth.token_type) $($oauth.access_token)"}
    $url = "https://graph.microsoft.com/beta/identityRiskEvents"
    $myReport = (Invoke-WebRequest -UseBasicParsing -Headers $headerParams -Uri $url)
    $ConvertedReport = ConvertFrom-Json -InputObject $myReport.Content 
    $XMLReportValues = $ConvertedReport.value #Collect initial results into array
    if ($ConvertedReport.value.count -lt 100)
        {
            $nextURL = $ConvertedReport."@odata.nextLink"
            if (($ConvertedReport.value.count -ne 0) -and ($nextURL -ne $null)){
            Do { #Collect any additional results into array
                     $nextURL = $ConvertedReport."@odata.nextLink"
                     $Report =  Invoke-WebRequest -UseBasicParsing -Headers $headerParams -Uri $nextURL
                     $ConvertedReport = ConvertFrom-Json -InputObject $Report.Content
                     $XMLReportValues += $ConvertedReport
                }
                While ($NextResults."@odata.nextLink" -ne $null)
         }

    #Place results into a CSV
    $AuditOutputCSV = $Pwd.Path + "\" + $tenantname + "_$reportname.csv"
    $XMLReportValues | select * | Export-csv $AuditOutputCSV -NoTypeInformation -Force -append
    Write-host "Security report for Identity Risk Events can be found at" $AuditOutputCSV "."
       }    

       if ($ConvertedReport.value.count -eq 0)
        {
        $AuditOutputCSV = $Pwd.Path + "\" + $tenantname + "_$reportname.txt"
        Get-Date |  Out-File -FilePath $AuditOutputCSV 
        "No Data Returned. This typically means either the tenant does not have Azure AD Premium licensing or that the report query succeeded however there were no entries in the report. " |  Out-File -FilePath $AuditOutputCSV -Append
        }
      
    }

}


$url = "https://graph.microsoft.com/beta/identityRiskEvents"
GetReport $url "identityRiskEvents" $tenantdomain

