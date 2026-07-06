
Function Get-NexposeReportSave{
<#
    .SYNOPSIS
        Save the configuration for a report definition. 
    .DESCRIPTION
        Save the configuration for a report definition.

    .PARAMETER ConfigID

    .PARAMETER Name
        
    .PARAMETER TemplateID

    .PARAMETER FileFormat

    .PARAMETER Filters

    .PARAMETER GenerateNow

    .PARAMETER DataModelVersion
    
    .EXAMPLE
      

#>
Param(
    [String]
    $ConfigID = -1,

    [Parameter(Mandatory=$True)]
    [String]
    $Name,

    [String]
    $TemplateID,

    [Parameter(Mandatory=$True)]
    [ValidateSet("pdf", "html", "rtf", "xml", "text", "csv", "db", "raw-xml", "raw-xml-v2", "ns-xml", "qualys-xml", "sql")]
    [String]
    $FileFormat,

    [String]
    $DataModelVersion = '1.1.0',

    [Parameter(Mandatory=$True)]
    [String]
    $Filters,
    
    [Switch]
    $GenerateNow
    )
Confirm-Session
$Generate = 0
If($GenerateNow){
 $Generate = 1
}

$ArrayFilters = $Filters.Split(',')

Foreach($Filter in $ArrayFilters){
$SeparatedFilters = $Filter.split(':')
$type = $SeparatedFilters[0]
$id = $SeparatedFilters[1]
$FilterElements += "<filter type='$type' id='$id' />"
}

$sites_request = "<ReportSaveRequest session-id='$SCRIPT:session_id'  generate-now='$Generate'><ReportConfig id='$ConfigID' name='$Name' template-id='$TemplateID' format='$FileFormat'><Filters>$FilterElements<filter type='version' id='$DataModelVersion' /></Filters><Users /><Generate /><Delivery><Storage storeOnServer='1' /></Delivery></ReportConfig></ReportSaveRequest> "
Write-Host $sites_request

$resp = Invoke-WebRequest -URI $uri -Body $sites_request -ContentType 'text/xml' -Method post
[xml]$xmldata = $resp.content
if($xmldata.ReportSaveResponse.success -like '0'){
    $xmldata.ReportSaveResponse.Failure.Exception
    }
    Else{
    $xmldata.ReportSaveResponse
    }
} 
