# Purpose: List-AllOnedriveSItes — SharePoint Online site administration.
<#
    ===========================================================================
     Created with:     VS Code
     Created on:       9/20/2018 1:46 PM
     Filename:         ListAllOnedriveSItes.ps1
    ===========================================================================
    .DESCRIPTION
       Get all one drive URLs
#>
#########Load function###############################################
function Write-Log {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [array]$Name,
        [Parameter(Mandatory = $true)]
        [string]$Ext,
        [Parameter(Mandatory = $true)]
        [string]$folder
    )

    $log = @()
    $date1 = get-date -format d
    $date1 = $date1.ToString().Replace("/", "-")
    $time = get-date -format t

    $time = $time.ToString().Replace(":", "-")
    $time = $time.ToString().Replace(" ", "")

    foreach ($n in $name) {

        $log += (Get-Location).Path + "\" + $folder + "\" + $n + "_" + $date1 + "_" + $time + "_.$Ext"
    }
    return $log
}
function LaunchSPO
{
    param
    (
        $orgName,
        $cred
    )

    Write-Host "Enter Sharepoint Online Credentials" -ForegroundColor Green
    $userCredential = $cred
    Connect-SPOService -Url "https://$orgName-admin.sharepoint.com" -Credential $userCredential
}

Function RemoveSPO
{

    disconnect-sposervice
}

##########################Load variables & Logs####################
$log = Write-Log -Name "process_Onedrive" -folder logs -Ext log
$report = Write-Log -Name "Onedriveurls" -folder Report -Ext html

$onedrivetemplate = "SPSPERS#9"
$orgname = "labtest"

$collection = @()

##########Start Script main##############

Start-Transcript -Path $log

try
    {
        LaunchSPO -orgName $orgname
    }
    catch
    {
        write-host "$($_.Exception.Message)" -foregroundcolor red
        break
    }
######################SPO Launched, now extract report#######
Write-host "Start generating Onedrive Urls" -ForegroundColor Green
$collection = Get-SPOSite -Template $onedrivetemplate -limit ALL -includepersonalsite $True | Select Owner,Title,Url
Write-host "Finished generating Onedrive Urls" -ForegroundColor Green
RemoveSPO
############Format HTML###########
$HTMLFormat = "<!--mce:0-->"
################################

$collection | select  Owner,Title,Url | ConvertTo-HTML -Head $HTMLFormat -Body "<H2><Font Size = 4,Color = DarkCyan>Onedrive Site URLS</Font></H2>" -AS Table |
Set-Content $report
get-date
Write-Host "Script finished" -ForegroundColor green
Stop-Transcript
######################################################################################