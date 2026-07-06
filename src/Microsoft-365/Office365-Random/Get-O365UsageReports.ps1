<#
.Synopsis
	Get-O365UsageReports gather all the Office 365 Usage Reports via Graph (Beta endpoint) and generates an Excel document

.DESCRIPTION
	This PowerShell script requires an Azure Application Client ID which has access to the Microsoft Graph's Read all usage reports permissions to pull the Office 365 Usage Report and save to an Excel document.
    $APIVersion defaults to the Microsoft Graft beta version, as the Teams usage reports are not currently in the v1.0 API.
    See: Manage-AzureAppRegistration: http://realtimeuc.com/2017/12/manage-azureappregistration

    VERSION:      	2.0

V 1.0 - Jan 2018 -	Fast Publish.
V 2.0 - Jan 2018 -	Graph Change, no DLL required.

.LINK
   Website: http://realtimeuc.com
   Twitter: http://www.twitter.com/realtimeuc
   LinkedIn: http://www.linkedin.com/in/mlamontagne/

.EXAMPLE
   $Results = .\Get-O365UsageReports.ps1
   
	Description
	-----------
	Prompts for Azure Tenant AD Domain Name (domain.onmicrosoft.com), prompts for Azure Application Client ID, prompts for credentials 
    before connecting to Microsoft Graph to pull the Office 365 Usage Reports for the last 30 days and saving to an Excel document in c:\temp\O365Reports.xlsx.
    Will also return the Usage Reports as a hashtable in $Results.
	
.EXAMPLE
	$cred = get-credential
    $Results = .\Get-O365UsageReports.ps1 -$AzureAppClientId '7d856782-ba2c-XXXX-a39e-778c33e4ecd4' -Credential $cred -period 'd180' -File 'c:\test\o365.xls' 
   
	Description
	-----------
    Connecting to Microsoft Graph to pull the Office 365 Usage Reports for the last 180 days and saving to an Excel document in c:\test\O365.xlsx.
    Will also return the Usage Reports as a hashtable in $Results.

.EXAMPLE
	$cred = get-credential
    $Results = .\Get-O365UsageReports.ps1 -$AzureAppClientId '7d856782-ba2c-XXXX-a39e-778c33e4ecd4' -Credential $cred -NoExcel
   
	Description
	-----------
    Connecting to Microsoft Graph to pull the Office 365 Usage Reports for the last 30 days and return the Usage Reports as a hashtable in $Results. Excel document output disabled.
    
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)] 
    [string]$AzureAppClientId,  #Azure Application Client ID with Microsoft Graph - Read all usage reports permissions, Manage-AzureAppRegistration: http://realtimeuc.com/2017/12/manage-azureappregistration
    [Parameter(Mandatory=$true)]
    [Pscredential]$Credential = $(Get-Credential),
    [ValidateSet('D7','D30','D90','D180')] #Reporting Period in Days. Valid entries:
    [string]$Period = 'D30',
    [switch]$NoExcel, #Switch to prevent Excel export
    [string]$File ='c:\temp\O365Reports.xlsx', #Excel file name
    [string]$APIVersion ='beta' #beta or v1.0
)

if(!$NoExcel){
    #Create File path if doesn't exist
    if(!(Test-Path (Split-Path -Path $File))){
	    New-Item -ItemType directory -Path (Split-Path -Path $File) | out-null
    }
    #Excel file check, will DELETE if exists!!!
    if($file.split('.').count -gt 1){
        if (test-path $file) { rm $file }   #delete existing file
    }
}

$Periods = @('D7','D30','D90','D180')
$Period = $Period.ToUpper()

#Raw data arrays
$objectCollection = @{}

#Request Graph API Token and build request header.
$resourceURL = "https://graph.microsoft.com/" #Resource URI to the Microsoft Graph

function Connect-Graph {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [pscredential]$Credential,
        
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]$ResourceURL = "https://graph.windows.net/",
        
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]$ClientID = '1950a258-227b-4e31-a9cf-717495945fc2'
    )
    $tokenArgs = @{
        grant_type = "password"
        resource   = $ResourceURL
        username   = $Credential.Username
        password   = $Credential.GetNetworkCredential().Password
        client_id  = $ClientID # from msonline extended
    }
    try {
        $token = Invoke-RestMethod -Uri https://login.microsoftonline.com/common/oauth2/token -body $tokenArgs -Method POST
        if($token) {
            # note we don't refresh so this token is only good for maybe 1 hour
            $Script:AadToken = "$($token.token_type) $($token.access_token)"
            $Script:AadHeader = @{
                "Authorization" = $Script:AadToken
                "Content-Type" = "application/json"
            }
            $true
        } else {
            $Script:AadToken = $false
            $Script:AadHeader = $false
            $false
        }
    } catch {
        $false
    }
}

function RestMethod {
    Param (
    [parameter(Mandatory=$true)]
    [ValidateSet("GET","POST","PATCH","DELETE", "PUT")]
    [String]$Method,

    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]$URI,

    [parameter(Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    $Headers=$Script:AadHeader,

    [parameter(Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [String]$Body
    )

    $RestResults = $null
   try {
        if ($PSBoundParameters.ContainsKey("Body")) {
            $RestResults = Invoke-RestMethod -Method $Method -Uri $URI -Headers $Headers -Body $Body -Verbose
        }
        else {
            $RestResults = Invoke-RestMethod -Method $Method -Uri $URI -Headers $Headers -Verbose
        }
     
    }
    catch {
        $result = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($result)
        $reader.BaseStream.Position = 0
        $reader.DiscardBufferedData()
        $responseBody = $reader.ReadToEnd()   
        $Message = $(($responseBody -split('"value":"') )[1] -split('"'))[0] 
        Write-error "$Message" 
        return $Message
    }

    return $RestResults
}



#Graph Usage Reports:
    #https://github.com/microsoftgraph/microsoft-graph-docs/blob/master/api-reference/beta/resources/report.md
    #https://developer.microsoft.com/en-us/graph/docs/api-reference/beta/resources/microsoft_teams_device_usage_reports
    #https://developer.microsoft.com/en-us/graph/docs/api-reference/beta/resources/microsoft_teams_user_activity_reports
$O365Reports = @(
    'getEmailActivityUserDetail';
    'getEmailActivityCounts';
    'getEmailActivityUserCounts';
    'getEmailAppUsageUserDetail';
    'getEmailAppUsageAppsUserCounts';
    'getEmailAppUsageUserCounts';
    'getEmailAppUsageVersionsUserCounts';
    'getMailboxUsageDetail';
    'getMailboxUsageMailboxCounts';
    'getMailboxUsageQuotaStatusMailboxCounts';
    'getMailboxUsageStorage';
    'getOffice365ActivationsUserDetail';
    'getOffice365ActivationCounts';
    'getOffice365ActivationsUserCounts';
    'getOffice365ActiveUserDetail';
    'getOffice365ActiveUserCounts';
    'getOffice365ServicesUserCounts';
    'getOffice365GroupsActivityDetail';
    'getOffice365GroupsActivityCounts';
    'getOffice365GroupsActivityGroupCounts';
    'getOffice365GroupsActivityStorage';
    'getOffice365GroupsActivityFileCounts';
    'getOneDriveActivityUserDetail';
    'getOneDriveActivityUserCounts';
    'getOneDriveActivityFileCounts';
    'getOneDriveUsageAccountDetail';
    'getOneDriveUsageAccountCounts';
    'getOneDriveUsageFileCounts';
    'getOneDriveUsageStorage';
    'getSharePointActivityUserDetail';
    'getSharePointActivityFileCounts';
    'getSharePointActivityUserCounts';
    'getSharePointActivityPages';
    'getSharePointSiteUsageDetail';
    'getSharePointSiteUsageFileCounts';
    'getSharePointSiteUsageSiteCounts';
    'getSharePointSiteUsageStorage';
    'getSharePointSiteUsagePages';
    'getSkypeForBusinessActivityUserDetail';
    'getSkypeForBusinessActivityCounts';
    'getSkypeForBusinessActivityUserCounts';
    'getSkypeForBusinessDeviceUsageUserDetail';
    'getSkypeForBusinessDeviceUsageDistributionUserCounts';
    'getSkypeForBusinessDeviceUsageUserCounts';
    'getSkypeForBusinessOrganizerActivityCounts';
    'getSkypeForBusinessOrganizerActivityUserCounts';
    'getSkypeForBusinessOrganizerActivityMinuteCounts';
    'getSkypeForBusinessParticipantActivityCounts';
    'getSkypeForBusinessParticipantActivityUserCounts';
    'getSkypeForBusinessParticipantActivityMinuteCounts';
    'getSkypeForBusinessPeerToPeerActivityCounts';
    'getSkypeForBusinessPeerToPeerActivityUserCounts';
    'getSkypeForBusinessPeerToPeerActivityMinuteCounts';
    'getteamsDeviceUsageUserDetail';
    'getteamsDeviceUsageUserCounts';
    'getteamsDeviceUsagedistributionUserCounts';
    'getteamsUserActivityUserDetail';
    'getteamsUserActivityCounts';
    'getteamsUserActivityUserCounts';
    'getYammerActivityUserDetail';
    'getYammerActivityCounts';
    'getYammerActivityUserCounts';
    'getYammerDeviceUsageUserDetail';
    'getYammerDeviceUsageDistributionUserCounts';
    'getYammerDeviceUsageUserCounts';
    'getYammerGroupsActivityDetail';
    'getYammerGroupsActivityGroupCounts';
    'getYammerGroupsActivityCounts'
)

#Get Graph Token
$connect = Connect-Graph $credential $resourceURL $AzureAppClientId

#Data gathering via Graph
if($connect){   
    foreach ($Report in $O365Reports){
        $Results = $null
        $Request = $null
        $ReportName = $null

        if($Periods -notcontains $Period -or $report -like "getOffice365Activation*"){
            $Request = "https://graph.microsoft.com/$($APIVersion)/reports/$($Report)"  
        }
        else{
            $Request = "https://graph.microsoft.com/$($APIVersion)/reports/$($Report)(period='$($Period)')"   
        }

        $Results = RestMethod -Method "Get" -URI $Request       
    
        #Shorten report name due to Excel limits
        $ReportName = $Report.ToLower()
        $ReportName = $ReportName.replace('peertopeer','p2p')
        $ReportName = $ReportName.replace('skypeforbusiness','sfb')
        $ReportName = $ReportName.replace('office365','o365')
        $ReportName = $ReportName.replace('minute','min')
        $ReportName = $ReportName.replace('distribution','dist')
        $ReportName = $ReportName.replace('get','')
        $ReportName = $ReportName.replace('counts','')	
    
        if($Results){
            $Results = $Results.replace("ï»¿","") | ConvertFrom-Csv
            if($Results){
                $Results | add-member –membertype NoteProperty –name 'Office365Report' –Value $ReportName 
                $objectCollection.Add($($ReportName),$Results)    
            }
            else{
               $objResults = New-Object –Type PSObject 
               $objResults | add-member –membertype NoteProperty –name 'Office365Report' –Value $ReportName  
               $objectCollection.Add($($ReportName),$objResults)  
            }
        }    
    }
}
if(!$NoExcel){
    #Excel object
    $Excel = New-Object -Com Excel.Application
    $Excel.Visible = $True
    $Excel.Workbooks.Add(1) | out-null
    $Workbook = $Excel.Workbooks.Item(1)

    #Modified Export-Excel function from: https://social.technet.microsoft.com/Forums/windows/en-US/abcf63ba-ce01-4e91-8bad-d5c42d2234e9/how-to-write-in-excel-via-powershell?forum=winserverpowershell
    function Export-Excel {
	    [cmdletBinding()]
	    Param(
		    [Parameter(ValueFromPipeline=$true)]
		    [string]$junk        )
	    begin{
		    $header = $null
		    $row = 1
            if($Workbook.WorkSheets.item(1).name -eq "sheet1"){
                $Worksheet = $Workbook.WorkSheets.item(1)
            }
            else{
                $Worksheet = $Workbook.Worksheets.Add()
            }
	    }
	    process{
		    if(!$header){
			    $i = 0
			    $header = $_ | Get-Member -MemberType NoteProperty | select name
			    $header | %{$Worksheet.cells.item(1,++$i)=$_.Name}
		    }
		    $i = 0
		    ++$row
		    foreach($field in $header){
			    $Worksheet.cells.item($row,++$i)=$($_."$($field.Name)")
		    }
	    }
	    end{
            $Worksheet.Name = $($_."Office365Report")
            $Worksheet.Columns.AutoFit() | out-null
            $Worksheet = $null
            $header = $null
	    }
    }

    #Loop for creating a worksheet for each report
    Foreach ($item in $objectCollection.Keys | sort -Descending){
       $objectCollection[$item] | Export-Excel
    }

    #Save Excel file
    $Workbook.SaveAs($file)
}

return $objectCollection


# SIG # Begin signature block
# MIIchAYJKoZIhvcNAQcCoIIcdTCCHHECAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUIaA7Sn2+8aBxie5qXNjm7R+j
# 8/ygghezMIIFMDCCBBigAwIBAgIQBAkYG1/Vu2Z1U0O1b5VQCDANBgkqhkiG9w0B
# AQsFADBlMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYD
# VQQLExB3d3cuZGlnaWNlcnQuY29tMSQwIgYDVQQDExtEaWdpQ2VydCBBc3N1cmVk
# IElEIFJvb3QgQ0EwHhcNMTMxMDIyMTIwMDAwWhcNMjgxMDIyMTIwMDAwWjByMQsw
# CQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cu
# ZGlnaWNlcnQuY29tMTEwLwYDVQQDEyhEaWdpQ2VydCBTSEEyIEFzc3VyZWQgSUQg
# Q29kZSBTaWduaW5nIENBMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA
# +NOzHH8OEa9ndwfTCzFJGc/Q+0WZsTrbRPV/5aid2zLXcep2nQUut4/6kkPApfmJ
# 1DcZ17aq8JyGpdglrA55KDp+6dFn08b7KSfH03sjlOSRI5aQd4L5oYQjZhJUM1B0
# sSgmuyRpwsJS8hRniolF1C2ho+mILCCVrhxKhwjfDPXiTWAYvqrEsq5wMWYzcT6s
# cKKrzn/pfMuSoeU7MRzP6vIK5Fe7SrXpdOYr/mzLfnQ5Ng2Q7+S1TqSp6moKq4Tz
# rGdOtcT3jNEgJSPrCGQ+UpbB8g8S9MWOD8Gi6CxR93O8vYWxYoNzQYIH5DiLanMg
# 0A9kczyen6Yzqf0Z3yWT0QIDAQABo4IBzTCCAckwEgYDVR0TAQH/BAgwBgEB/wIB
# ADAOBgNVHQ8BAf8EBAMCAYYwEwYDVR0lBAwwCgYIKwYBBQUHAwMweQYIKwYBBQUH
# AQEEbTBrMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wQwYI
# KwYBBQUHMAKGN2h0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFz
# c3VyZWRJRFJvb3RDQS5jcnQwgYEGA1UdHwR6MHgwOqA4oDaGNGh0dHA6Ly9jcmw0
# LmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcmwwOqA4oDaG
# NGh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RD
# QS5jcmwwTwYDVR0gBEgwRjA4BgpghkgBhv1sAAIEMCowKAYIKwYBBQUHAgEWHGh0
# dHBzOi8vd3d3LmRpZ2ljZXJ0LmNvbS9DUFMwCgYIYIZIAYb9bAMwHQYDVR0OBBYE
# FFrEuXsqCqOl6nEDwGD5LfZldQ5YMB8GA1UdIwQYMBaAFEXroq/0ksuCMS1Ri6en
# IZ3zbcgPMA0GCSqGSIb3DQEBCwUAA4IBAQA+7A1aJLPzItEVyCx8JSl2qB1dHC06
# GsTvMGHXfgtg/cM9D8Svi/3vKt8gVTew4fbRknUPUbRupY5a4l4kgU4QpO4/cY5j
# DhNLrddfRHnzNhQGivecRk5c/5CxGwcOkRX7uq+1UcKNJK4kxscnKqEpKBo6cSgC
# PC6Ro8AlEeKcFEehemhor5unXCBc2XGxDI+7qPjFEmifz0DLQESlE/DmZAwlCEIy
# sjaKJAL+L3J+HNdJRZboWR3p+nRka7LrZkPas7CM1ekN3fYBIM6ZMWM9CBoYs4Gb
# T8aTEAb8B4H6i9r5gkn3Ym6hU/oSlBiFLpKR6mhsRDKyZqHnGKSaZFHvMIIFPDCC
# BCSgAwIBAgIQCdJTfUMAFGkDgmfJ2joXlTANBgkqhkiG9w0BAQsFADByMQswCQYD
# VQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGln
# aWNlcnQuY29tMTEwLwYDVQQDEyhEaWdpQ2VydCBTSEEyIEFzc3VyZWQgSUQgQ29k
# ZSBTaWduaW5nIENBMB4XDTE4MDgyNzAwMDAwMFoXDTE5MDkwNDEyMDAwMFoweTEL
# MAkGA1UEBhMCQ0ExEDAOBgNVBAgTB0FsYmVydGExEDAOBgNVBAcTB0NhbGdhcnkx
# IjAgBgNVBAoTGUxhTW9udGFnbmUgU29sdXRpb25zIEluYy4xIjAgBgNVBAMTGUxh
# TW9udGFnbmUgU29sdXRpb25zIEluYy4wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAw
# ggEKAoIBAQDH64llTd4U8I5Z9jiZ8Uz/Rl4+Mufn13SFHGN+24AYgBBFU2+HnROt
# ylF02L3T3QUwPZAGnE8k/5l+pLlJcDMf3cGwGJiN1Z0dDy1maP8vbLtieTZFZHel
# FywuZAg9AwLbMyiPjYre97i9FR9Wz+rcafPzKW7MF1fb0ulHdWlvY4PfOjLnYqUa
# kNTh0p2NouNIaO6IzB5s0x/SbBpAeXGw5kdNmSCYEQBNskXGHUL6XBapham6qOBJ
# KDYqu1gdw23qo5ZzWO2Ujy5z8IbrxmZ8I0dymJwPePwwdvusY/amW2LI75+jKjbe
# l1zcv/31XfWysDamgUAhNKUuYFRRemaBAgMBAAGjggHFMIIBwTAfBgNVHSMEGDAW
# gBRaxLl7KgqjpepxA8Bg+S32ZXUOWDAdBgNVHQ4EFgQUFEO8+tT7MwW0rmTULEk9
# 5ziOEmMwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMHcGA1Ud
# HwRwMG4wNaAzoDGGL2h0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9zaGEyLWFzc3Vy
# ZWQtY3MtZzEuY3JsMDWgM6Axhi9odHRwOi8vY3JsNC5kaWdpY2VydC5jb20vc2hh
# Mi1hc3N1cmVkLWNzLWcxLmNybDBMBgNVHSAERTBDMDcGCWCGSAGG/WwDATAqMCgG
# CCsGAQUFBwIBFhxodHRwczovL3d3dy5kaWdpY2VydC5jb20vQ1BTMAgGBmeBDAEE
# ATCBhAYIKwYBBQUHAQEEeDB2MCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdp
# Y2VydC5jb20wTgYIKwYBBQUHMAKGQmh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNv
# bS9EaWdpQ2VydFNIQTJBc3N1cmVkSURDb2RlU2lnbmluZ0NBLmNydDAMBgNVHRMB
# Af8EAjAAMA0GCSqGSIb3DQEBCwUAA4IBAQDcALG3VKV6ZM0Kd7OAUBhdqpVqmjZ/
# LYRaoYFSZyQ8+yyes0r8odxzY8sNLx2v6+BN90aqeAOrp/2MKWCjjY2qdedZeHVe
# 5TAAjbwlf+MDhcIFxVeX/bh1tcMaYPS8JUIu40GoZOi4xzH5hIelU6G+eFBVxbEc
# BzGz6c4sgPNDkg5QS/NKsNQ++9SwNsBHLuEaoN0jYLYe6BHgdUaG96CCl4PbbaL3
# uy0n5sQCB3oEyDquBfX6pAVX2WBVZeSQhefLFJtFVZoka5yQPG0kinpbrFQx+2Ly
# CBPbUN0+9p2rrdgJtlQvL2lywnESxtBvMcHsQWsCD4qLSV+eTjvG0NuHMIIGajCC
# BVKgAwIBAgIQAwGaAjr/WLFr1tXq5hfwZjANBgkqhkiG9w0BAQUFADBiMQswCQYD
# VQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGln
# aWNlcnQuY29tMSEwHwYDVQQDExhEaWdpQ2VydCBBc3N1cmVkIElEIENBLTEwHhcN
# MTQxMDIyMDAwMDAwWhcNMjQxMDIyMDAwMDAwWjBHMQswCQYDVQQGEwJVUzERMA8G
# A1UEChMIRGlnaUNlcnQxJTAjBgNVBAMTHERpZ2lDZXJ0IFRpbWVzdGFtcCBSZXNw
# b25kZXIwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCjZF38fLPggjXg
# 4PbGKuZJdTvMbuBTqZ8fZFnmfGt/a4ydVfiS457VWmNbAklQ2YPOb2bu3cuF6V+l
# +dSHdIhEOxnJ5fWRn8YUOawk6qhLLJGJzF4o9GS2ULf1ErNzlgpno75hn67z/RJ4
# dQ6mWxT9RSOOhkRVfRiGBYxVh3lIRvfKDo2n3k5f4qi2LVkCYYhhchhoubh87ubn
# NC8xd4EwH7s2AY3vJ+P3mvBMMWSN4+v6GYeofs/sjAw2W3rBerh4x8kGLkYQyI3o
# BGDbvHN0+k7Y/qpA8bLOcEaD6dpAoVk62RUJV5lWMJPzyWHM0AjMa+xiQpGsAsDv
# pPCJEY93AgMBAAGjggM1MIIDMTAOBgNVHQ8BAf8EBAMCB4AwDAYDVR0TAQH/BAIw
# ADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDCCAb8GA1UdIASCAbYwggGyMIIBoQYJ
# YIZIAYb9bAcBMIIBkjAoBggrBgEFBQcCARYcaHR0cHM6Ly93d3cuZGlnaWNlcnQu
# Y29tL0NQUzCCAWQGCCsGAQUFBwICMIIBVh6CAVIAQQBuAHkAIAB1AHMAZQAgAG8A
# ZgAgAHQAaABpAHMAIABDAGUAcgB0AGkAZgBpAGMAYQB0AGUAIABjAG8AbgBzAHQA
# aQB0AHUAdABlAHMAIABhAGMAYwBlAHAAdABhAG4AYwBlACAAbwBmACAAdABoAGUA
# IABEAGkAZwBpAEMAZQByAHQAIABDAFAALwBDAFAAUwAgAGEAbgBkACAAdABoAGUA
# IABSAGUAbAB5AGkAbgBnACAAUABhAHIAdAB5ACAAQQBnAHIAZQBlAG0AZQBuAHQA
# IAB3AGgAaQBjAGgAIABsAGkAbQBpAHQAIABsAGkAYQBiAGkAbABpAHQAeQAgAGEA
# bgBkACAAYQByAGUAIABpAG4AYwBvAHIAcABvAHIAYQB0AGUAZAAgAGgAZQByAGUA
# aQBuACAAYgB5ACAAcgBlAGYAZQByAGUAbgBjAGUALjALBglghkgBhv1sAxUwHwYD
# VR0jBBgwFoAUFQASKxOYspkH7R7for5XDStnAs0wHQYDVR0OBBYEFGFaTSS2STKd
# Sip5GoNL9B6Jwcp9MH0GA1UdHwR2MHQwOKA2oDSGMmh0dHA6Ly9jcmwzLmRpZ2lj
# ZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRENBLTEuY3JsMDigNqA0hjJodHRwOi8v
# Y3JsNC5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURDQS0xLmNybDB3Bggr
# BgEFBQcBAQRrMGkwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNv
# bTBBBggrBgEFBQcwAoY1aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lD
# ZXJ0QXNzdXJlZElEQ0EtMS5jcnQwDQYJKoZIhvcNAQEFBQADggEBAJ0lfhszTbIm
# gVybhs4jIA+Ah+WI//+x1GosMe06FxlxF82pG7xaFjkAneNshORaQPveBgGMN/qb
# sZ0kfv4gpFetW7easGAm6mlXIV00Lx9xsIOUGQVrNZAQoHuXx/Y/5+IRQaa9Ytnw
# Jz04HShvOlIJ8OxwYtNiS7Dgc6aSwNOOMdgv420XEwbu5AO2FKvzj0OncZ0h3RTK
# FV2SQdr5D4HRmXQNJsQOfxu19aDxxncGKBXp2JPlVRbwuwqrHNtcSCdmyKOLChzl
# ldquxC5ZoGHd2vNtomHpigtt7BIYvfdVVEADkitrwlHCCkivsNRu4PQUCjob4489
# yq9qjXvc2EQwggbNMIIFtaADAgECAhAG/fkDlgOt6gAK6z8nu7obMA0GCSqGSIb3
# DQEBBQUAMGUxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAX
# BgNVBAsTEHd3dy5kaWdpY2VydC5jb20xJDAiBgNVBAMTG0RpZ2lDZXJ0IEFzc3Vy
# ZWQgSUQgUm9vdCBDQTAeFw0wNjExMTAwMDAwMDBaFw0yMTExMTAwMDAwMDBaMGIx
# CzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3
# dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERpZ2lDZXJ0IEFzc3VyZWQgSUQgQ0Et
# MTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAOiCLZn5ysJClaWAc0Bw
# 0p5WVFypxNJBBo/JM/xNRZFcgZ/tLJz4FlnfnrUkFcKYubR3SdyJxArar8tea+2t
# sHEx6886QAxGTZPsi3o2CAOrDDT+GEmC/sfHMUiAfB6iD5IOUMnGh+s2P9gww/+m
# 9/uizW9zI/6sVgWQ8DIhFonGcIj5BZd9o8dD3QLoOz3tsUGj7T++25VIxO4es/K8
# DCuZ0MZdEkKB4YNugnM/JksUkK5ZZgrEjb7SzgaurYRvSISbT0C58Uzyr5j79s5A
# XVz2qPEvr+yJIvJrGGWxwXOt1/HYzx4KdFxCuGh+t9V3CidWfA9ipD8yFGCV/QcE
# ogkCAwEAAaOCA3owggN2MA4GA1UdDwEB/wQEAwIBhjA7BgNVHSUENDAyBggrBgEF
# BQcDAQYIKwYBBQUHAwIGCCsGAQUFBwMDBggrBgEFBQcDBAYIKwYBBQUHAwgwggHS
# BgNVHSAEggHJMIIBxTCCAbQGCmCGSAGG/WwAAQQwggGkMDoGCCsGAQUFBwIBFi5o
# dHRwOi8vd3d3LmRpZ2ljZXJ0LmNvbS9zc2wtY3BzLXJlcG9zaXRvcnkuaHRtMIIB
# ZAYIKwYBBQUHAgIwggFWHoIBUgBBAG4AeQAgAHUAcwBlACAAbwBmACAAdABoAGkA
# cwAgAEMAZQByAHQAaQBmAGkAYwBhAHQAZQAgAGMAbwBuAHMAdABpAHQAdQB0AGUA
# cwAgAGEAYwBjAGUAcAB0AGEAbgBjAGUAIABvAGYAIAB0AGgAZQAgAEQAaQBnAGkA
# QwBlAHIAdAAgAEMAUAAvAEMAUABTACAAYQBuAGQAIAB0AGgAZQAgAFIAZQBsAHkA
# aQBuAGcAIABQAGEAcgB0AHkAIABBAGcAcgBlAGUAbQBlAG4AdAAgAHcAaABpAGMA
# aAAgAGwAaQBtAGkAdAAgAGwAaQBhAGIAaQBsAGkAdAB5ACAAYQBuAGQAIABhAHIA
# ZQAgAGkAbgBjAG8AcgBwAG8AcgBhAHQAZQBkACAAaABlAHIAZQBpAG4AIABiAHkA
# IAByAGUAZgBlAHIAZQBuAGMAZQAuMAsGCWCGSAGG/WwDFTASBgNVHRMBAf8ECDAG
# AQH/AgEAMHkGCCsGAQUFBwEBBG0wazAkBggrBgEFBQcwAYYYaHR0cDovL29jc3Au
# ZGlnaWNlcnQuY29tMEMGCCsGAQUFBzAChjdodHRwOi8vY2FjZXJ0cy5kaWdpY2Vy
# dC5jb20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3J0MIGBBgNVHR8EejB4MDqg
# OKA2hjRodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURS
# b290Q0EuY3JsMDqgOKA2hjRodHRwOi8vY3JsNC5kaWdpY2VydC5jb20vRGlnaUNl
# cnRBc3N1cmVkSURSb290Q0EuY3JsMB0GA1UdDgQWBBQVABIrE5iymQftHt+ivlcN
# K2cCzTAfBgNVHSMEGDAWgBRF66Kv9JLLgjEtUYunpyGd823IDzANBgkqhkiG9w0B
# AQUFAAOCAQEARlA+ybcoJKc4HbZbKa9Sz1LpMUerVlx71Q0LQbPv7HUfdDjyslxh
# opyVw1Dkgrkj0bo6hnKtOHisdV0XFzRyR4WUVtHruzaEd8wkpfMEGVWp5+Pnq2LN
# +4stkMLA0rWUvV5PsQXSDj0aqRRbpoYxYqioM+SbOafE9c4deHaUJXPkKqvPnHZL
# 7V/CSxbkS3BMAIke/MV5vEwSV/5f4R68Al2o/vsHOE8Nxl2RuQ9nRc3Wg+3nkg2N
# sWmMT/tZ4CMP0qquAHzunEIOz5HXJ7cW7g/DvXwKoO4sCFWFIrjrGBpN/CohrUkx
# g0eVd3HcsRtLSxwQnHcUwZ1PL1qVCCkQJjGCBDswggQ3AgEBMIGGMHIxCzAJBgNV
# BAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdp
# Y2VydC5jb20xMTAvBgNVBAMTKERpZ2lDZXJ0IFNIQTIgQXNzdXJlZCBJRCBDb2Rl
# IFNpZ25pbmcgQ0ECEAnSU31DABRpA4Jnydo6F5UwCQYFKw4DAhoFAKB4MBgGCisG
# AQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQw
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFIxQ
# gYR1tDKgA2aIg1dfflnY8USMMA0GCSqGSIb3DQEBAQUABIIBAHljIX6MyUlpZS+R
# uN3GP+19BVBbfs3NA7un4Cld6duuAA+qSDdxmVWaPuGOeVdWleR+9ObjKT4r2xYN
# 5Hweu7ch9xnYU2No9Ct8DxKV3d26F6KMHeX0gTYI89FEcN2mkvJR2OOzTVky7ONZ
# TPD1wDl1I7MWwyku8qTDQ6DFMcjMg+IkL1pGN5jn6D9hxLVu5mss3/7R3+G1f+16
# /HqgS+bjvzE9UxOHS1sqcDmqVcsgjUzD/hlvRwG6XNG4BvhtD5k/LQHQbUWaNfCz
# R3eE8cbsde+dXgRjEtP+6Ko045mo3NYVcr2i0hSHnWpUn76Fhp5cAfHrWhnIRdCx
# cy3olBWhggIPMIICCwYJKoZIhvcNAQkGMYIB/DCCAfgCAQEwdjBiMQswCQYDVQQG
# EwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNl
# cnQuY29tMSEwHwYDVQQDExhEaWdpQ2VydCBBc3N1cmVkIElEIENBLTECEAMBmgI6
# /1ixa9bV6uYX8GYwCQYFKw4DAhoFAKBdMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0B
# BwEwHAYJKoZIhvcNAQkFMQ8XDTE4MDgyNzIxNTI1OVowIwYJKoZIhvcNAQkEMRYE
# FORxe3PCR48Z6v28qFUNQMTbesZMMA0GCSqGSIb3DQEBAQUABIIBAHPD58kAoVSq
# L91tfLxtC9omD8bzDvsqciMnftZjDQpvqP960ZjwFZokv1y3NiFtyUKIfkmmEUqc
# gJ/UNTpVARwb7hcIxjJye7LelDJza2CFtcre1MpLCOGPPhgeTL0VLfjjAfxvOsKJ
# PplGHBLx+koPV9eb1IhFZSqIn3Of/EWopTzV5Kq4dIyIkqSgDB2m/uS4ZdsQ/725
# p8UQZvaqpc5Vd/cNB+LIVIVnbSbkMw1exD1kSTKzSZuBtwiNpeRVbNbonVpx3Rd9
# aMv2biZfE7BcifMEsiMBJmv043DSFLidAgEAkAuXOhqntixS5APjuNMHJxZ8sk1a
# wt+nI8wmC78=
# SIG # End signature block
