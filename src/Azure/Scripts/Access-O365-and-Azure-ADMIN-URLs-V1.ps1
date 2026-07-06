# Purpose: Access-O365 and Azure ADMIN URLs — Microsoft Azure cloud resource management.
<#
# Script      : Access-O365-and-Azure-ADMIN-URLs-V1
# Author(s)   : Brandon Stevens
# Date        : 10/25/2019 21:51:59
# Org         : Anomalix Inc.
# File Name   : Access-O365-and-Azure-ADMIN-URLs-V1.ps1
# Comments    : This was wrote in windows and need to transfer cmd.exe to Terminal
# Description : O365 & Azure Admin Management Portal
# Assumptions :

.EXAMPLE
  .\Access-O365-and-Azure-ADMIN-URLs-V1.ps1

  MAP:
  -----------
  #(1)_.O365 ECP Console
  #(2)_.O365 Sec & Comp Cente
  #(3)_.O365 Quarantine Management
  #(4)_.O365 One Drive Admin Console
  #(5)_.O365 Teams Admin Console
  #(6)_.O365 SharePoint Admin Console
  #(7)_.O365 AZURE Admin Console
  #(8)_.O365 One Drive Admin Console
  #(9)_.O365 Access OWA
  #(1)_.Run Function to present MENU and Selections
  #

#>

# FUNCTIONS LIST

#(1)_.O365 ECP Console
function Function-Open-ECP-V1
{

#Var URLS
$ECP = "https://outlook.office.com/ecp"
# Open ECP with IE
[system.Diagnostics.Process]::Start("$ECP") | Out-Null

}

#(2)_.O365 Sec & Comp Center
function Function-Open-SecCop-V1
{

#Var URLS
$SecCop = "https://protection.office.com"
# Open ECP with IE
[system.Diagnostics.Process]::Start("$SecCop") | Out-Null

}
#(3)_.O365 Qurantine Management
function Function-Open-quarantine-V1
{

#Var URLS
$quarantine = "https://protection.office.com/?hash=/quarantine"
# Open ECP with IE
[system.Diagnostics.Process]::Start("$quarantine") | Out-Null

}
#(4)_.O365 One Drive Admin Console
function Function-Open-OneDrive-V1
{

#Var URLS
$OneDrive = "https://admin.onedrive.com/"
# Open ECP with IE
[system.Diagnostics.Process]::Start("$OneDrive") | Out-Null

}
#(5)_.O365 Teams Admin Console
function Function-Open-Teams-V1
{

#Var URLS
$Teams = "https://admin.teams.microsoft.com"
# Open ECP with IE
[system.Diagnostics.Process]::Start("$Teams") | Out-Null

}
#(6)_.O365 SharePoint Admin Console
function Function-Open-SPadmin-V1
{

#Var URLS
$SPadmin = "https://tenant-admin.sharepoint.com"
# Open ECP with IE
[system.Diagnostics.Process]::Start("$SPadmin") | Out-Null

}
#(7)_.O365 AZURE Admin Console
function Function-Open-AzurePort-V1
{

#Var URLS
$AzurePort = "http://aad.portal.azure.come"
# Open ECP with IE
[system.Diagnostics.Process]::Start("$AzurePort") | Out-Null

}
#(8)_.O365 One Drive Admin Console
function Function-Open-AdminPort-V1
{

#Var URLS
$AdminPort = "https://admin.microsoft.com/AdminPortal/Home#/homepage"
# Open ECP with IE
[system.Diagnostics.Process]::Start("$AdminPort") | Out-Null

}
#(9)_.O365 Access OWA
function Function-Open-OWA-V1
{

#Var URLS
$OWA = "https://outlook.office365.com/owa"
# Open ECP with IE
[system.Diagnostics.Process]::Start("$OWA") | Out-Null

}

#######################################################

#(1)_.Run Function to present MENU and Selections
function Function-O365-ADMIN-URL
{
    param (
        [string]$Title = 'O365  ADMIN CONSOLE URL ACCESS Tool'

    )
    Clear-Host
    Write-host $null
    Write-Host "$Title"
    Write-Host "================================================"
    Write-Host "(1): Press '1'  ECP Admin Console" -f Cyan
    Write-Host "(2): Press '2'  SecCop Admin Console" -f Cyan
    Write-Host "(3): Press '3'  Quarantine Management Console" -f Cyan
    Write-Host "(4): Press '4'  One Drive Admin Console" -f Cyan
    Write-Host "(5): Press '5'  Teams Admin Console" -f Cyan
    Write-Host "(6): Press '6'  SharePoint Admin Console" -f Cyan
    Write-Host "(7): Press '7'  AZURE Admin Console" -f Cyan
    Write-Host "(8): Press '8'  Quarantine Admin Console" -f Cyan
    Write-Host "(9): Press '9'  Open OWA" -f Cyan
    Write-Host $null
    Write-Host "(1): Press 'a' Start PowerShell" -f Green
    Write-Host "(2): Press 'b' Start cmd.exe" -f Green
    Write-Host "(3): Press 'c' Start ADUC" -f Green
    Write-Host "ACTION: Press 'Q' to quit."-f Yellow
    Write-Host "================================================"

}

do
 {
     Function-O365-ADMIN-URL
     Write-host $null
     $selection = Read-Host "Please Select Option"
     switch ($selection)
    {
         '1' {Function-Open-ECP-V1}
         '2' {Function-Open-SecCop-V1}
         '3' {Function-Open-Quarantine-V1}
         '4' {Function-Open-OneDrive-V1}
         '5' {Function-Open-Teams-V1}
         '6' {Function-Open-SPadmin-V1}
         '7' {Function-Open-AzurePort-V1}
         '8' {Function-Open-Quarantine-V1}
         '9' {Function-Open-OWA-V1}

         'a' {open -n -a Terminal  PowerShell}
         'b' {open -n -a Terminal}
         'c' {Start dsa.msc}
     }
     pause
 }
 until ($selection -eq 'q')

 #######################################################

