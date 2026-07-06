
Function Get-FilterAsset{
<#
    .SYNOPSIS
        Interact with the filtering capabilities in Nexpose.
    .DESCRIPTION
        Interact with the filtering capabilities in Nexpose. Please read up on what operators work with which fieldnames.
            
    .PARAMETER operator
        AND/OR this will dictate whether the filter matches on all or any filter.

    .PARAMETER fieldname
        What are we filtering on: ASSET, CVE_ID, CVSS_ACCESS_COMPLEXITY, CVSS_ACCESS_VECTOR, CVSS_AUTHENTICATION_REQUIRED, CVSS_AVAILABILITY_IMPACT, CVSS_CONFIDENTIALITY_IMPACT, CVSS_INTEGRITY_IMPACT, CVSS_SCORE, 
        HOST_TYPE, IP_ADDRESS_TYPE, IP_ALT_ADDRESS_TYPE, IP_RANGE, OS, PCI_COMPLIANCE_STATUS, RISK_SCORE, SCAN_DATE, SERVICE, SITE_ID, SOFTWARE, USER_ADDED_CRITICALITY_LEVEL, USER_ADDED_CUSTOM_TAG, USER_ADDED_TAG_LOCATION
        USER_ADDED_TAG_OWNER, VALIDATED_VULNERABILITIES, VULNERABILITY, VULNERABILITY_EXPOSURES, VULN_CATEGORY
    
    .EXAMPLE
      Get-FilterAsset -fieldname 'IP_RANGE' -operator 'IS' -value '6.130.152.230'

#>
Param([String] $operator = 'AND', [String] [Parameter(Mandatory=$true)] $fieldname, [String] [Parameter(Mandatory=$true)] $FieldnameOperator, [String] [Parameter(Mandatory=$true)] $value)
$cookie = New-Object System.Net.Cookie
$cookie.Name = 'nexposeCCSessionID'
$cookie.Value = "$SCRIPT:session_id"
$cookie.Domain = "$server"

$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$session.Cookies.Add($cookie)
$headers = @{}
$headers.Add("Accept","text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8")
$headers.Add("nexposeCCSessionID","$SCRIPT:session_id")
$headers.Add("X-Requested-With","XMLHttpRequest")
$headers.Add("Content-Type","application/x-www-form-urlencoded; charset=UTF-8")
$Criteria = "{`"operator`":`"$operator`", `"criteria`":[{`"metadata`":{`"fieldName`":`"$fieldname`"},`"operator`":`"$FieldnameOperator`",`"values`":[`"$value`"]}]}"


$postParams = @{sort=-1;dir=-1;startIndex=-1;results=-1;'table-id'='assetfilter';searchCriteria=$Criteria }
$directory = "https://$SCRIPT:server/data/asset/filterAssets"
$resp = Invoke-WebRequest $directory -WebSession $session -Headers $headers -Method POST -Body $postParams | ConvertFrom-Json
#$totalnum = ($resp).totalRecords
#$postParams = @{sort='assetOSName';dir='DESC';startIndex=1;results=$totalnum;'table-id'='assetfilter';searchCriteria=$Criteria }
#$resp = Invoke-WebRequest $directory -WebSession $session -Headers $headers -Method POST -Body $postParams | ConvertFrom-Json
$resp

}
