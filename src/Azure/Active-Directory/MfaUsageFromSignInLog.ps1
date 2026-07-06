#####################################################################################################################################
#####################################################################################################################################

<#
.SYNOPSIS

    Creates a Grid View containing Azure AD MFA usage

.DESCRIPTION

    Produces a custom Grid View of MFA usage from available Sign-In logs, using mfaDetail and authenticationDetails fields to filter.
    
    Update the tenant ID to customise the script.

    NB - uses the MSAL.PS module from the PS Gallery - https://www.powershellgallery.com/packages/MSAL.PS

.EXAMPLE

    .\MfaUsageFromSignInLog.ps1

    Creates a Grid View of MFA usage from available Sign-In logs

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

#Requires -Module MSAL.ps
#Version: 3.0

#####################################################################################################################################

###########################################
#### MODIFY TO CHANGE SCRIPT BEHAVIOUR ####
###########################################


#Specify the target tenant
$TenantId = "***_YOUR_TENANT_ID***"


#####################################################################################################################################

###################################
#DO NOT MODIFY THE BELOW LINES ####
###################################

############################################################################

#Function to construct a header for the web request (with token)

function Get-Headers {
    
    param($Token)

    return @{

        "Authorization" = ("Bearer {0}" -f $Token);
        "Content-Type" = "application/json";

    }

}   #end function


############################################################################

#Function to get a token for MS Graph with PowerShell client ID

function Get-AzureADApiToken {

    ############################################################################

    <#
    .SYNOPSIS

        Get an access token for use with the API cmdlets.


    .DESCRIPTION

        Check the global $TokenObtained variable. 
       
        If true, i.e. we've previously obtained a token, will attempt a refresh. 

        If false, i.e. we haven't previously obtained a token, will attempt an 
        interactive authentication. 


    .EXAMPLE

        Get-AzureADApiToken -TenantId b446a536-cb76-4360-a8bb-6593cf4d9c7f

        Gets or refreshes an access token for making API calls for the tenant ID
        b446a536-cb76-4360-a8bb-6593cf4d9c7f.


    #>

    ############################################################################

    [CmdletBinding()]
    param(

        #The tenant ID
        [Parameter(Mandatory,Position=0)]
        [string]$TenantId

    )


    ############################################################################


    #Get an access token using the PowerShell client ID
    $ClientId = "1b730954-1685-4b74-9bfd-dac224a7b894"
    $RedirectUri = "urn:ietf:wg:oauth:2.0:oob"
    $Authority = "https://login.microsoftonline.com/$TenantId"
    
    if ($TokenObtained) {

        Write-Verbose -Message "$(Get-Date -f T) - Attempting to refresh an existing access token"

        #Attempt to refresh access token
        try {

            $Response = Get-MsalToken -ClientId $ClientId -RedirectUri $RedirectUri -Authority $Authority -ForceRefresh
        }
        catch {}

        #Error handling for token acquisition
        if ($Response) {

            Write-Verbose -Message "$(Get-Date -f T) - API Access Token refreshed - new expiry: $(($Response).ExpiresOn.UtcDateTime)"

            return $Response

        }
        else {
            
            Write-Warning -Message "$(Get-Date -f T) - Failed to refresh Access Token - try re-running the cmdlet again"

        }

    }
    else {

        Write-Verbose -Message "$(Get-Date -f T) - Please input a credential or select an existing account"

        #Run this to interactvely obtain an access token
        try {

            $Response = Get-MsalToken -ClientId $ClientId -RedirectUri $RedirectUri -Authority $Authority -Interactive
        }
        catch {}

        #Error handling for token acquisition
        if ($Response) {

            Write-Verbose -Message "$(Get-Date -f T) - API Access Token obtained"

            #Global variable to show we've already obtained a token
            $TokenObtained = $true

            return $Response

        }
        else {

            Write-Warning -Message "$(Get-Date -f T) - Failed to obtain an Access Token - try re-running the cmdlet again"

        }

    }


}   #end function


############################################################################

#Try and get MSAL.ps module 
$MSAL = Get-Module -ListAvailable MSAL.ps -Verbose:$false -ErrorAction SilentlyContinue

if ($MSAL) {

    #API endpoint
    $Url = "https://graph.microsoft.com/beta/auditLogs/signIns"

    #Get / refresh an access token
    $Token = (Get-AzureADApiToken -TenantId $TenantId).AccessToken

    if ($Token) {

        #Construct header with access token
        $Headers = Get-Headers($Token)

        #Tracking variables
        $Count = 0
        $RetryCount = 0
        $OneSuccessfulFetch = $false
        $TotalReport = $null


        #Do until the fetch URL is null
        do {

            Write-Verbose -Message "$(Get-Date -f T) - Invoking web request for $Url"

            ##################################
            #Do our stuff with error handling
            try {

                #Invoke the web request
                $MyReport = (Invoke-WebRequest -UseBasicParsing -Headers $Headers -Uri $Url -Verbose:$false)

            }
            catch [System.Net.WebException] {
        
                $StatusCode = [int]$_.Exception.Response.StatusCode
                Write-Warning -Message "$(Get-Date -f T) - $($_.Exception.Message)"

                #Check what's gone wrong
                if (($StatusCode -eq 401) -and ($OneSuccessfulFetch)) {

                    #Token might have expired; renew token and try again
                    $Token = (Get-AzureADApiToken -TenantId $TenantId).AccessToken
                    $Headers = Get-Headers($Token)
                    $OneSuccessfulFetch = $False

                }
                elseif (($StatusCode -eq 429) -or ($StatusCode -eq 504) -or ($StatusCode -eq 503)) {

                    #Throttled request or a temporary issue, wait for a few seconds and retry
                    Start-Sleep -Seconds 5

                }
                elseif (($StatusCode -eq 403) -or ($StatusCode -eq 401)) {

                    Write-Warning -Message "$(Get-Date -f T) - Please check the permissions of the user"
                    break

                }
                elseif ($StatusCode -eq 400) {

                    Write-Warning -Message "$(Get-Date -f T) - Please check the query used"
                    break

                }
                else {
            
                    #Retry up to 5 times
                    if ($RetryCount -lt 5) {
                
                        Write-Host "Retrying..."
                        $RetryCount++

                    }
                    else {
                
                        #Write to host and exit loop
                        Write-Warning -Message "$(Get-Date -f T) - Download request failed. Please try again in the future"
                        break

                    }

                }

            }
            catch {

                #Write error details to host
                Write-Warning -Message "$(Get-Date -f T) - $($_.Exception)"


                #Retry up to 5 times    
                if ($RetryCount -lt 5) {

                    Write-Host "Retrying..."
                    $RetryCount++

                }
                else {

                    #Write to host and exit loop
                    Write-Warning -Message "$(Get-Date -f T) - Download request failed - please try again in the future"
                    break

                }

            } # end try / catch


            ###############################
            #Convert the content from JSON
            $ConvertedReport = ($MyReport.Content | ConvertFrom-Json).value

            #Pick out MFA
            $ConvertedReport = $ConvertedReport | Where-Object {($_.mfaDetail -ne $null) -and ($_.authenticationDetails -ne $null)}

            #Add to concatenated findings
            [array]$TotalReport += $ConvertedReport

            #Update the fetch url to include the paging element
            $Url = ($myReport.Content | ConvertFrom-Json).'@odata.nextLink'

            #Update tracking variables
            $OneSuccessfulFetch = $true
            $RetryCount = 0

        
        } while ($Url -ne $null) #end do / while

    }

    #Throw the results up to screen with Out-GridView
    $TotalReport | 
    Select CreatedDateTime,UserDisplayName,UserPrincipalName,AppDisplayName,ConditionalAccessStatus,IsInteractive,Status,MfaDetail,AuthenticationDetails |
    Out-GridView -Title "MFA usage from Sign-Ins"

}
else {

    Write-Warning -Message "$(Get-Date -f T) - Please install the MSAL.ps PowerShell module (Find-Module MSAL.ps)"    

}

