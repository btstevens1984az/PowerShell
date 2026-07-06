<#PSScriptInfo


.GUID f87d9255-2a64-483f-8a73-4bb04ba556b1


.COMPANYNAME 

.COPYRIGHT 

.TAGS 

.LICENSEURI 

.PROJECTURI 

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES


#>

<# 

.DESCRIPTION 
 DL all Gallery modules 

#> 


workflow Download-AllGalleryModules
{ 
<#
.Synopsis
   This Workflow will download all the Modules in the PowerShell Gallery to a location that you specify (could be a Shared Drive)
.DESCRIPTION
   This uses the foreach -parallel switch in the workflow to massively speed up the download process.
.PARAMETER OutPath
   Used for the location to dump the Module files
.EXAMPLE
   Download-AllGalleryModules -OutPath C:\GalleryModules\
   #>
param ( 
    [Parameter(Mandatory=$true,Position=0)] 
    [string]$Outpath
    )

if (!(Test-Path $Outpath))
    {New-Item $Outpath -ItemType Directory}

$modules = Find-Module * -IncludeDependencies | Sort-Object Name

foreach -parallel -throttlelimit 25 ($module in $modules) 
    { Save-Module $module.Name -Path $Outpath -Force }

}

Download-AllGalleryModules -Outpath C:\PS\modules\AllGalleryModules
