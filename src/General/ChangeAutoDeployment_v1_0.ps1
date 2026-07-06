# Purpose: ChangeAutoDeployment v1 0 — General-purpose PowerShell utilities.
##################################################################################################################################################
# Project: Change Auto Deployment (Package)
# Date: 19-5-2013
# By: Peter van der Woude
# Version: 1.0 Public
# Usage: PowerShell.exe -ExecutionPolicy ByPass .\ChangeAutoDeployment_v1_0.ps1 -SiteCode <SiteCode> -SiteServer <SiteServer> - AutoDeploymentName <AutoDeploymentName> -PackageId <PackageId>
##################################################################################################################################################

[CmdletBinding()]

param (
[string]$SiteCode,
[string]$SiteServer,
[string]$AutoDeploymentName,
[string]$PackageId
)

function Change-ContentTemplate {
    [wmi]$AutoDeployment = (Get-WmiObject -Class SMS_AutoDeployment -Namespace root/SMS/site_$($SiteCode) -ComputerName $SiteServer | Where-Object -FilterScript {$_.Name -eq $AutoDeploymentName}).__PATH
    [xml]$ContentTemplateXML = $AutoDeployment.ContentTemplate

    $ContentTemplateXML.ContentActionXML.PackageId = $PackageId
    
    $AutoDeployment.ContentTemplate = $ContentTemplateXML.OuterXML
    $AutoDeployment.Put()
}

Change-ContentTemplate