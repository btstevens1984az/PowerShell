# Purpose: Windows10Sophia — Windows desktop configuration and management.

[CmdletBinding()]
param
(
	[Parameter(Mandatory = $false)]
	[string[]]
	$Functions
)

Clear-Host

$Host.UI.RawUI.WindowTitle = 'Windows Sophia Script | Copyright farag2 & Inestic, 2014 to 2021'
Remove-Module -Name Sophia -Force -ErrorAction Ignore
Import-Module -Name $PSScriptRoot\Manifest\Sophia.psd1 -PassThru -Force
Import-LocalizedData -BindingVariable Global:Localization -FileName Sophia -BaseDirectory $PSScriptRoot\Localizations

#region Protection


#endregion Protection

#region Privacy & Telemetry


#endregion Privacy & Telemetry

#region UI & Personalization


#endregion UI & Personalization

#region OneDrive


#endregion OneDrive

#region System


#endregion System

#region WSL


#endregion WSL

#region Start menu


#endregion Start menu

#region UWP apps


#endregion UWP apps

#region Gaming


#endregion Gaming

#region Scheduled tasks


#endregion Scheduled tasks

#region Microsoft Defender & Security


#endregion Microsoft Defender & Security

#region Context menu


#endregion Context menu

RefreshEnvironment
Errors