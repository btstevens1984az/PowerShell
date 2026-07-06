<#
.SYNOPSIS 
Install Office365 PowerShell Prerequisites
 
.DESCRIPTION  
Downloads and installs the AzureAD, Sharepoint Online, Skype Online for Windows PowerShell

.Made by 
Edwin van brenk

.Date
23-12-2019

.Source
https://vanbrenk.blogspot.com/2018/03/install-office365-requirements-with.html
#>             
            
Function InstallSharepointOnlinePowerShellModule() {

$SharepointOnlinePowerShellModuleSourceURL = "https://download.microsoft.com/download/0/2/E/02E7E5BA-2190-44A8-B407-BC73CA0D6B87/SharePointOnlineManagementShell_9119-1200_x64_en-us.msi"

$DestinationFolder = "C:\Temp"

     If (!(Test-Path $DestinationFolder))
     {             
         New-Item $DestinationFolder -ItemType Directory -Force
     }
       
Write-Host "Downloading Sharepoint Online PowerShell Module from $SharepointOnlinePowerShellModuleSourceURL"

     try
     {
         Invoke-WebRequest -Uri $SharepointOnlinePowerShellModuleSourceURL -OutFile "$DestinationFolder\SharePointOnlineManagementShell_7414-1200_x64_en-us.msi" -ErrorAction STOP

$msifile = "$DestinationFolder\SharePointOnlineManagementShell_7414-1200_x64_en-us.msi"
$arguments = @(
          "/i"             
          "`"$msiFile`""             
          "/passive"            
)

Write-Host "Attempting to install $msifile"

         $process = Start-Process -FilePath msiexec.exe -Wait -PassThru -ArgumentList $arguments
         if ($process.ExitCode -eq 0)
         {
             Write-Host "$msiFile has been successfully installed"
         }
         else
         {
             Write-Host "installer exit code  $($process.ExitCode) for file  $($msifile)"
         }

     }
     catch
     {
         Write-Host $_.Exception.Message
     }
 }

InstallSharepointOnlinePowerShellModule

# Download and Install Visual Studio C++ 2017            
$VisualStudio2017x64URL = "https://download.visualstudio.microsoft.com/download/pr/11687625/2cd2dba5748dc95950a5c42c2d2d78e4/VC_redist.x64.exe"            
Write-Host "Downloading VisualStudio 2017 C++ from $VisualStudio2017x64"             
            
$DestinationFolder = "C:\Temp"            
            
Invoke-WebRequest -Uri $VisualStudio2017x64URL -OutFile "$DestinationFolder\VC_redist.x64.exe" -ErrorAction STOP            
            
Write-Host "Attempting to install VisualStudio 2017 C++, a reboot is required!"            
             
Start-Process "$DestinationFolder\VC_redist.x64.exe" -ArgumentList "/passive /norestart" -Wait            
            
Write-Host "Attempting to install VisualStudio 2017 C++"             
             
# Download and Install Skype Online PowerShell module            
$SkypeOnlinePowerShellModuleSourceURL = "https://download.microsoft.com/download/2/0/5/2050B39B-4DA5-48E0-B768-583533B42C3B/SkypeOnlinePowerShell.Exe"
                 
$DestinationFolder = "C:\Temp"
             
     If (!(Test-Path $DestinationFolder))
     {
         New-Item $DestinationFolder -ItemType Directory -Force
     }

Write-Host "Downloading Skype Online PowerShell Module from $SkypeOnlinePowerShellModuleSourceURL"
             
Invoke-WebRequest -Uri $SkypeOnlinePowerShellModuleSourceURL -OutFile "$DestinationFolder\SkypeOnlinePowerShell.Exe" -ErrorAction STOP
            
Start-Process "$DestinationFolder\SkypeOnlinePowerShell.Exe" -ArgumentList "/quiet" -Wait             
# Register PSGallery PSprovider and set as Trusted source
Register-PSRepository -Default
Set-PSRepository -Name PSGallery -InstallationPolicy trusted

# Install modules from PSGallery
Install-Module -Name AzureAD -Force
Install-Module -Name MSOnline -Force
Install-Module -Name AZ -Force
Install-Module -Name MicrosoftTeams -Force
Install-Module -Name Microsoft.Graph.Intune -Force
Install-Module -Name MicrosoftStaffHub -RequiredVersion 1.0.0-alpha -AllowPrerelease
Install-Module PowershellGet -Force
Install-Module -Name ExchangeOnlineManagement
# Manually install 222.205.193.149 Online with MFA authentication support from the 222.205.193.149 Online ECP            
Write-Host "Login, go to Hybrid and download the 222.205.193.149 Online Powershell module"            
Start-Process https://outlook.office365.com/ecp/