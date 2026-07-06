# Purpose: AllHostProfile — Storage management and disk operations.
if (test-path "$($env:OneDrive)\Documents\scripts")
{
$OneDriveScriptPath ="$($env:OneDrive)\Documents\scripts" 
$oneDriveModulePath = "$($env:OneDrive)\Powershell\Modules"
}
elseif (test-path "$HOME\SkyDrive\Documents\scripts")
{$OneDriveScriptPath ="$HOME\SkyDrive\Documents\scripts" 
$oneDriveModulePath = "$HOME\SkyDrive\Powershell\Modules"}
else
{write-error -Message "Cannot find OneDrive"
 exit 
  }
if (!(test-path scripts:) -and (Test-path $OneDriveScriptPath ) )
{New-PSDrive -Name scripts -PSProvider FileSystem -Root $OneDriveScriptPath }
if (!(test-path Modules:) -and (Test-path $oneDriveModulePath ) )
{New-PSDrive -Name Modules -PSProvider FileSystem -Root $oneDriveModulePath}
. scripts:\Functions\Search-Bing.ps1
. scripts:\Functions\ShowObject.ps1
. scripts:\Functions\GetDemoComputers.ps1
If (-not (test-path c:\temp))
{
    mkdir C:\Temp
}
Set-Location C:\temp
#Clear-Host