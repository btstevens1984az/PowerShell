#####################################################################################################################################
#####################################################################################################################################

<#
.SYNOPSIS

    Creates a CSV file containing user credential registration details for MFA or SSPR

.DESCRIPTION

    Produces a date and time-stamped CSV file containing user credential registration details. 
    
    Update the tenant ID and the filter options to customise the script.

    Filter options (one only):

        * all user details
        * users registered for SSPR
        * users enabled for SSPR
        * users capable of resetting their passwords
        * users registered for MFA


    NB - uses the ADAL.PS module from the PS Gallery - https://www.powershellgallery.com/packages/ADAL.PS

.EXAMPLE

    .\DownloadAzureADUserCredentialDetails.ps1

    Creates a date and time stamped CSV file, in the script execution diectory, containing user details gathered 
    with the selected filter.

    THIS CODE-SAMPLE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED 
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR 
    FITNESS FOR A PARTICULAR PURPOSE.

    This sample is not supported under any Microsoft standard support program or service. 
    The script is provided AS IS without warranty of any kind. Microsoft further disclaims all
    implied warranties including, without limitation, any implied warranties of merchantability
    or of fitness for a particular purpose. The entire risk arising out of the use or performance
    of the sample and documentation remains with you. In no event shall Microsoft, its authors,
    or anyone else involved in the creation, production, or delivery of the script be liable for 
    any damages whatsoever (including, without limitation, damages for loss of business profits, 
    business interruption, loss of business information, or other pecuniary loss) arising out of 
    the use of or inability to use the sample or documentation, even if Microsoft has been advised 
    of the possibility of such damages, rising out of the use of or inability to use the sample script, 
    even if Microsoft has been advised of the possibility of such damages. 

#>

#####################################################################################################################################

#Requires -Module ADAL.ps
#Version: 3.0

#####################################################################################################################################

###########################################
#### MODIFY TO CHANGE SCRIPT BEHAVIOUR ####
###########################################

#Specify the target tenant
$TenantId = "***_YOUR_TENANT_ID***"


#Pick the required filter; comment out the others; only one allowed
$filter = ""                                       #all user details
#$filter = "&`$filter=(isRegistered eq true)"      #users registered for SSPR
#$filter = "&`$filter=(isEnabled eq true)"         #users enabled for SSPR
#$filter = "&`$filter=(isCapable eq true)"         #users capable of resetting their passwords
#$filter = "&`$filter=(isMfaRegistered eq true)"   #users registered for MFA


#Output file
$now = "{0:yyyyMMdd_hhmmss}" -f (Get-Date)
$outputFile = "UserCredentialRegistrationDetails_$now.csv"



#####################################################################################################################################

###################################
#DO NOT MODIFY THE BELOW LINES ####
###################################

#Load the MSAL.PS module
Import-Module -Name ADAL.PS


#API endpoint
$url = "https://graph.microsoft.com/beta/reports/credentialUserRegistrationDetails?`$orderby=userDisplayName asc" + $filter


##################
#region functions

#Function to create a CSV friendly object for conversion
function Expand-AuthMethodCollection {
    [cmdletbinding()]
    param (
        [parameter(ValueFromPipeline)]
        [psobject]$MSGraphObject
    )
    
    begin {

        #mark that we don't have properties
        $IsSchemaObtained = $False

    }

    process {
        
        #if fisrt iteration get output properties
        if (!$IsSchemaObtained) {

            $OutputOrder = $MSGraphObject.psobject.properties.name
            $IsSchemaObtained = $true

        }

        #Loop thorugh the supplied object and process individually
        $MSGraphObject | ForEach-Object {

            #Capture each element
            $singleGraphObject = $_

            #New parent object for edited / expanded values
            $ExpandedObject = New-Object -TypeName PSObject

            #Loop through the properties
            $OutputOrder | ForEach-Object {

                #Auth methods has to have commas added
                if ($_ -eq "authMethods") {
                    
                    #Ensure we have a non-empty value if there's nothing in authMethods
                    $CSVLine = " "

                    #Get variables from authMethods property
                    $Properties = $singleGraphObject.$($_)

                    #Loop thorugh each property and add to a single string with a seperating comma (for CSV)
                    $Properties | ForEach-Object {

                        $CSVLine += "$_,"

                    }

                    #Add edited list of values for authmethods property to parent object
                    Add-Member -InputObject $ExpandedObject -MemberType NoteProperty -Name $_ -Value $CSVLine.TrimEnd(0,",")

                }
                else {

                    #Add single value property to parent object
                    Add-Member -InputObject $ExpandedObject -MemberType NoteProperty -Name $_ -Value $(($singleGraphObject.$($_) | Out-String).Trim())

                }

            }

            #Return completed parent object
            $ExpandedObject
        }

    }

}   #end function


#Function to construct a header for the web request (with token)
function Get-Headers {
    
    param($token)

    return @{

        "Authorization" = ("Bearer {0}" -f $token);
        "Content-Type" = "application/json";

    }

}   #end function

#endregion functions


#############
#region main

#Get an access token using the PS client ID
$resourceUrl = "https://graph.microsoft.com"
$clientId = "1b730954-1685-4b74-9bfd-dac224a7b894"   #PowerShell clientId
$redirectUri = "urn:ietf:wg:oauth:2.0:oob"
$authority = "https://login.microsoftonline.com/$tenantId"

$response = Get-ADALToken -Resource $resourceUrl -ClientId $clientId -RedirectUri $redirectUri -Authority $authority -PromptBehavior:SelectAccount
$token = $response.AccessToken 

    #error handling for token acquisition
    if ($token -eq $null) {

        Write-Host "ERROR: Failed to get an Access Token"
        exit

    }


#Message to host
Write-Host "--------------------------------------------------------------"
Write-Host "Downloading report from $url"
Write-Host "Output file: $outputFile"
Write-Host "--------------------------------------------------------------"


#Construct header with access token
$headers = Get-Headers($token)

#Tracking variables
$count = 0
$retryCount = 0
$oneSuccessfulFetch = $false
$oneSuccessfulWrite = $false


#Do until the fetch URL is null
do {

    #Write query to host
    Write-Host "Fetching data using Url: $url"

    ##################################
    #Do our stuff with error handling
    try {

        #Invoke the web request
        $myReport = (Invoke-WebRequest -UseBasicParsing -Headers $headers -Uri $url)

    }
    catch [System.Net.WebException] {
        
        $statusCode = [int]$_.Exception.Response.StatusCode
        Write-Host $statusCode
        Write-Host $_.Exception.Message

        #Check what's gone wrong
        if ($statusCode -eq 401 -and $oneSuccessfulFetch) {

            #Token might have expired; renew token and try again
            $response = Get-ADALToken -Resource $resourceUrl -ClientId $clientId -RedirectUri $redirectUri -Authority $authority -PromptBehavior:Auto
            $token = $response.AccessToken 
            $headers = Get-Headers($token)
            $oneSuccessfulFetch = $False

        }
        elseif (($statusCode -eq 429) -or ($statusCode -eq 504) -or ($statusCode -eq 503)) {

            #Throttled request or a temporary issue, wait for a few seconds and retry
            Write-Host "Temporary issue. Sleep before retry..."
            Start-Sleep -Seconds 5

        }
        elseif (($statusCode -eq 403) -or ($statusCode -eq 400) -or ($statusCode -eq 401)) {

            #Premission issue
            Write-Host "Please check the permissions of the user"
            break

        }
        else {
            
            #Retry up to 5 times
            if ($retryCount -lt 5) {
                
                Write-Host "Retrying..."
                $retryCount++

            }
            else {
                
                #Write to host and exit loop
                Write-Host "Download request failed. Please try again in the future."
                break

            }

        }

    }
    catch {
        
        #Get error information
        $exType = $_.Exception.GetType().FullName
        $exMsg = $_.Exception.Message

        #Write error details to host
        Write-Host "Exception: $_.Exception"
        Write-Host "Error Message: $exType"
        Write-Host "Error Message: $exMsg"


        #Retry up to 5 times    
        if ($retryCount -lt 5) {

            Write-Host "Retrying..."
            $retryCount++

        }
        else {

            #Write to host and exit loop
            Write-Host "Download request failed. Please try again in the future."
            break

        }

    } # end try / catch


    ###############################
    #Convert the content from JSON
    $convertedReport = ($myReport.Content | ConvertFrom-Json).value

    #Ensure the content is CSV friendly
    $csvOutput = $convertedReport | Expand-AuthMethodCollection | ConvertTo-Csv -NoTypeInformation 
        
    #Determine if we need to write the CSV header
    if ($oneSuccessfulWrite) {

        #Add content without CSV header
        Add-Content -Value $csvOutput[1..($csvOutput.Length-1)] -Path $outputFile

    }
    else {

        #Add content with CSV header
        Add-Content -Value $csvOutput -Path $outputFile

    }

    #Update the fetch url to include the paging element
    $url = ($myReport.Content | ConvertFrom-Json).'@odata.nextLink'

    #Update count and show for this cycle
    $count = $count+$convertedReport.Count
    Write-Host "Total Fetched: $count"

    #Update tracking variables
    $oneSuccessfulFetch = $true
    $oneSuccessfulWrite = $true
    $retryCount = 0

    Write-Host "--------------------------------------------------------------"


} while ($url -ne $null) #end do / while

#endregion main

#####################################################################################################################################
#####################################################################################################################################