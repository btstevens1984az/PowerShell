<# 
 
.SYNOPSIS
    Get-AADPendingDevices PowerShell script.

.DESCRIPTION
    Get-AADPendingDevices.ps1 is a PowerShell script helps to get all PENDING devices in Azure AD tenant.

.AUTHOR:
    Mohammad Zmaili


.PARAMETER
    OnScreenReport
    Displays PENDING devices on PowerShell screen.

.PARAMETER
    SavedCreds
    Uses the saved credentials option to connect to MSOnline.
    You can use any normal CLOUD only user who is having read permission to verify the devices. 
    But you have to use a global admin when using clean parameter.
    Notes: - This parameter is very helpful when automating/running the script in task scheduler.
           - Update the saved credentials under the section "Update Saved credentials".

.PARAMETER
    CleanDevices


.PARAMETER
    ExcelReport
    Generates Excel report and saves the result into it, if this switch not selected script will generate a CSV report.


.EXAMPLE
    .\Get-AADPendingDevices
    Retreives all PENDING devices in your tenant, and generates a CSV file with the output.


.EXAMPLE
    .\Get-AADPendingDevices.ps1 -CleanDevices -OnScreenReport
    Retreives all PENDING devices in your tenant, and generates a CSV file with the output, and displays the result on PowerShell screen.


.EXAMPLE
    .\Get-AADPendingDevices -CleanDevices
    Deletes PENDING devices from the tenant


.EXAMPLE
    .\Get-AADPendingDevices -SavedCreds
    Retreives all PENDING devices in your tenant, uses the saved credentials to access MSOnline.
    Note: You can automate running this script using task scheduler.


Script Output:
-----------

===================================
|Azure AD Pending Devices Summary:|
===================================
Number of affected devices: 7
#>

[cmdletbinding()]
param(
        [Parameter( Mandatory=$false)]
        [switch]$CleanDevices,
     
        [Parameter( Mandatory=$false)]
        [switch]$SavedCreds,

        [Parameter( Mandatory=$false)]
        [switch]$OnScreenReport,
        
        [Parameter( Mandatory=$false)]
        [switch]$ExcelReport

      )


# Update Saved credentials
$UserName = "user@domain.com"
$UserPass="PWD"
$UserPass=$UserPass|ConvertTo-SecureString -AsPlainText -Force
$UserCreds = New-Object System.Management.Automation.PsCredential($userName,$UserPass)


Function CheckInternet
{
$statuscode = (Invoke-WebRequest -Uri https://adminwebservice.microsoftonline.com/ProvisioningService.svc).statuscode
if ($statuscode -ne 200){
''
''
Write-Host "Operation aborted. Unable to connect to Azure AD, please check your internet connection." -ForegroundColor red -BackgroundColor Black
exit
}
}

Function CheckMSOnline{
''
Write-Host "Checking MSOnline Module..." -ForegroundColor Yellow
                            
    if (Get-Module -ListAvailable -Name MSOnline) {
        Import-Module MSOnline
        Write-Host "MSOnline Module has imported." -ForegroundColor Green -BackgroundColor Black
        ''

            Write-Host "Checking MSOnline version..." -ForegroundColor Yellow
            $MVersion = Get-Module msonline | Select-Object version
            if (($MVersion.Version.Major -eq 1) -and ($MVersion.Version.Minor -eq 1) -and ($MVersion.Version.Build -ge 183)){
                Write-Host "You have a supported version." -ForegroundColor Green -BackgroundColor Black
            }else{
                Write-Host "You have an old version." -ForegroundColor Red -BackgroundColor Black
                ''
                Write-Host "Updating MSOnline version..." -ForegroundColor Yellow
                Update-Module msonline -force
                Remove-Module msonline
                Import-Module msonline
                $MVersion = Get-Module msonline | Select-Object version
                if (($MVersion.Version.Major -eq 1) -and ($MVersion.Version.Minor -eq 1) -and ($MVersion.Version.Build -ge 183)){
                Write-Host "MSOnline Module has been updated. Please reopen PowerShell window." -ForegroundColor Green -BackgroundColor Black
                exit
                }else{
                Write-Host "Operation aborted. MSOnline module has not updated, please make sure you are running PowerShell as admin." -ForegroundColor red -BackgroundColor Black
                exit
                }

            }

        ''
        Write-Host "Connecting to MSOnline..." -ForegroundColor Yellow
        
        if ($SavedCreds){
            Connect-MsolService -Credential $UserCreds -ErrorAction SilentlyContinue
        }else{
            Connect-MsolService -ErrorAction SilentlyContinue
        }

        if (-not (Get-MsolCompanyInformation -ErrorAction SilentlyContinue)){
            Write-Host "Operation aborted. Unable to connect to MSOnline, please check you entered a correct credentials and you have the needed permissions." -ForegroundColor red -BackgroundColor Black
            exit
        }
        Write-Host "Connected to MSOnline successfully." -ForegroundColor Green -BackgroundColor Black
        ''
    } else {
        Write-Host "MSOnline Module is not installed." -ForegroundColor Red -BackgroundColor Black
        Write-Host "Installing MSOnline Module....." -ForegroundColor Yellow
        CheckInternet
        Install-Module MSOnline -force
                                
        if (Get-Module -ListAvailable -Name MSOnline) {                                
        Write-Host "MSOnline Module has installed." -ForegroundColor Green -BackgroundColor Black
        Import-Module MSOnline
        Write-Host "MSOnline Module has imported." -ForegroundColor Green -BackgroundColor Black
        ''
        Write-Host "Connecting to MSOnline..." -ForegroundColor Yellow
        Connect-MsolService -ErrorAction SilentlyContinue
        
        if (-not (Get-MsolCompanyInformation -ErrorAction SilentlyContinue)){
            Write-Host "Operation aborted. Unable to connect to MSOnline, please check you entered a correct credentials and you have the needed permissions." -ForegroundColor red -BackgroundColor Black
            exit
        }
        Write-Host "Connected to MSOnline successfully." -ForegroundColor Green -BackgroundColor Black
        ''
        } else {
        ''
        ''
        Write-Host "Operation aborted. MsOnline was not installed." -ForegroundColor red -BackgroundColor Black
        exit
        }
    }



}

Function CheckImportExcel{
''
Write-Host "Checking ImportExcel Module..." -ForegroundColor Yellow
                            
    if (Get-Module -ListAvailable -Name ImportExcel) {
        Import-Module ImportExcel
        Write-Host "ImportExcel Module has imported." -ForegroundColor Green -BackgroundColor Black
        ''
        ''
    } else {
        Write-Host "ImportExcel Module is not installed." -ForegroundColor Red -BackgroundColor Black
        ''
        Write-Host "Installing ImportExcel Module....." -ForegroundColor Yellow
        Install-Module ImportExcel -Force
                                
        if (Get-Module -ListAvailable -Name ImportExcel) {                                
        Write-Host "ImportExcel Module has installed." -ForegroundColor Green -BackgroundColor Black
        Import-Module ImportExcel
        Write-Host "ImportExcel Module has imported." -ForegroundColor Green -BackgroundColor Black
        ''
        ''
        } else {
        ''
        ''
        Write-Host "Operation aborted. ImportExcel was not installed." -ForegroundColor red -BackgroundColor Black
        exit
        }
    }



}

cls

'==================================================='
Write-Host '           Get Azure AD Pending Devices                          ' -ForegroundColor Green 
'==================================================='
''                    


CheckMSOnline

$rep=@()
$Devices=@()
$Devices= Get-MsolDevice -all -IncludeSystemManagedDevices
$DevCount = $Devices.Count
$DevNum=1
ForEach ($Device in $Devices){

    $a="Checking device number " + $DevNum +" out of " + $DevCount + " devices in your tenant ..."
    Write-Progress -Activity $a -PercentComplete (($DevNum*100)/$DevCount)
    #if ($Device.AlternativeSecurityIds){
    if ( ($Device.DeviceTrustType -eq 'Domain Joined') -and (-not([string]($Device.AlternativeSecurityIds)).StartsWith("X509:")) ){

            $rep+=$Device
    }
    $DevNum+=1
}

$Date=("{0:s}" -f (get-date)).Split("T")[0] -replace "-", ""
$Time=("{0:s}" -f (get-date)).Split("T")[1] -replace ":", ""

$date2=("{0:s}" -f ($global:lastLogon)).Split("T")[0] -replace "-", ""

$workSheetName = "AADPendingDevices-" + $date2



if ($rep.Count -ge 1){
    $rep | select Enabled, ObjectId, DeviceId, DisplayName, DeviceObjectVersion, DeviceOsType, DeviceOsVersion, DeviceTrustType, DeviceTrustLevel, ApproximateLastLogonTimestamp, DirSyncEnabled, LastDirSyncTime, @{Name=’Registeredowners’;Expression={[string]::join(“;”, ($_.Registeredowners))}}, @{Name=’DevicePhysicalIds’;Expression={[string]::join(“;”, ($_.DevicePhysicalIds))}}, @{Name=’AlternativeSecurityIds’;Expression={[string]::join(“;”, ($_.AlternativeSecurityIds))}}


    if ($CleanDevices){
        $rep | Remove-MsolDevice -force

            if ($ExcelReport){
                CheckImportExcel
                $filerep = "DeletedAADPendingDevices_" + $Date + $Time + ".xlsx"  
                $rep | select Enabled, ObjectId, DeviceId, DisplayName, DeviceObjectVersion, DeviceOsType, DeviceOsVersion, DeviceTrustType, DeviceTrustLevel, ApproximateLastLogonTimestamp, DirSyncEnabled, LastDirSyncTime, @{Name=’Registeredowners’;Expression={[string]::join(“;”, ($_.Registeredowners))}}, @{Name=’DevicePhysicalIds’;Expression={[string]::join(“;”, ($_.DevicePhysicalIds))}}, @{Name=’AlternativeSecurityIds’;Expression={[string]::join(“;”, ($_.AlternativeSecurityIds))}} | Export-Excel -workSheetName $workSheetName -path $filerep -ClearSheet -TableName "AADDevicesTable" -AutoSize
            }else{
                $filerep = "DeletedAADPendingDevices_" + $Date + $Time + ".csv"
                $rep | select Enabled, ObjectId, DeviceId, DisplayName, DeviceObjectVersion, DeviceOsType, DeviceOsVersion, DeviceTrustType, DeviceTrustLevel, ApproximateLastLogonTimestamp, DirSyncEnabled, LastDirSyncTime, @{Name=’Registeredowners’;Expression={[string]::join(“;”, ($_.Registeredowners))}}, @{Name=’DevicePhysicalIds’;Expression={[string]::join(“;”, ($_.DevicePhysicalIds))}}, @{Name=’AlternativeSecurityIds’;Expression={[string]::join(“;”, ($_.AlternativeSecurityIds))}} | Export-Csv -path $filerep -NoTypeInformation
            }

''
''
Write-Host "==========================================="
Write-Host "|Deleted Azure AD Pending Devices Summary:|"
Write-Host "==========================================="
Write-Host "Number of deleted devices:" $rep.count
''
$loc=Get-Location
Write-host $filerep "report has been created on the path:" $loc -ForegroundColor green -BackgroundColor Black
''


    }else{

            if ($ExcelReport){
                CheckImportExcel
                $filerep = "AADPendingDevices_" + $Date + $Time + ".xlsx"  
                $rep | select Enabled, ObjectId, DeviceId, DisplayName, DeviceObjectVersion, DeviceOsType, DeviceOsVersion, DeviceTrustType, DeviceTrustLevel, ApproximateLastLogonTimestamp, DirSyncEnabled, LastDirSyncTime, @{Name=’Registeredowners’;Expression={[string]::join(“;”, ($_.Registeredowners))}}, @{Name=’DevicePhysicalIds’;Expression={[string]::join(“;”, ($_.DevicePhysicalIds))}}, @{Name=’AlternativeSecurityIds’;Expression={[string]::join(“;”, ($_.AlternativeSecurityIds))}} | Export-Excel -workSheetName $workSheetName -path $filerep -ClearSheet -TableName "AADDevicesTable" -AutoSize
            }else{
                $filerep = "AADPendingDevices_" + $Date + $Time + ".csv"
                $rep | select Enabled, ObjectId, DeviceId, DisplayName, DeviceObjectVersion, DeviceOsType, DeviceOsVersion, DeviceTrustType, DeviceTrustLevel, ApproximateLastLogonTimestamp, DirSyncEnabled, LastDirSyncTime, @{Name=’Registeredowners’;Expression={[string]::join(“;”, ($_.Registeredowners))}}, @{Name=’DevicePhysicalIds’;Expression={[string]::join(“;”, ($_.DevicePhysicalIds))}}, @{Name=’AlternativeSecurityIds’;Expression={[string]::join(“;”, ($_.AlternativeSecurityIds))}} | Export-Csv -path $filerep -NoTypeInformation
            }


''
''
Write-Host "==================================="
Write-Host "|Azure AD Pending Devices Summary:|"
Write-Host "==================================="
Write-Host "Number of affected devices:" $rep.count
''
$loc=Get-Location
Write-host $filerep "report has been created on the path:" $loc -ForegroundColor green
''

    }




}else{
''
''
Write-Host "Task completed successfully." -ForegroundColor Yellow -BackgroundColor Black
Write-Host "There is no PENDING devices in your tenant" -ForegroundColor green -BackgroundColor Black
''
}


if ($OnScreenReport) {
    $rep | Out-GridView -Title "Hybrid Devices Health Check Report"
}