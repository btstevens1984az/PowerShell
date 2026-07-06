# -----------------------------------------------------------------------------------------
# Script: Initialize-UI.ps1
# Date: April 24, 2015
# Version: 1.0
# Purpose: This script is used to start the xamlGUI in a separate runspace. This 
#          script loads up the XAML file that displays the UI and hooks up the events
#          that drive the xamlUI.
#
# Project: foreScript
#
# -----------------------------------------------------------------------------------------
#
# (C) Nigel Thomas, 2015
#
#------------------------------------------------------------------------------------------

#Requires -version 3

#Set-StrictMode -Version Latest

# Global variables


# Set the working directory to the startup path of the script
$StartupLocation = Split-Path $script:MyInvocation.MyCommand.Path
#$StartupLocation = [System.AppDomain]::CurrentDomain.BaseDirectory.TrimEnd('\')
Set-Location $StartupLocation
[System.IO.Directory]::SetCurrentDirectory($StartupLocation)

#Set-Location $StartupLocation

<#if ($xamlGUI) {
   Remove-Variable xamlGUI
}#>



# Hashtable to synchronize between the UI runspace and other runspaces
$xamlGUI = [hashtable]::Synchronized(@{})


# Single Thread Apartment runspace needs to be created to run the WPF based UI
$xamlGUIRunspace =[Runspacefactory]::CreateRunspace()
$xamlGUIRunspace.ApartmentState = 'STA'
#$xamlGUIRunspace.ThreadOptions = 'UseCurrentThread'
        
$xamlGUIRunspace.Open()
$xamlGUIRunspace.SessionStateProxy.SetVariable('xamlGUI',$xamlGUI) 
$xamlGUIRunspace.SessionStateProxy.SetVariable('StartupLocation',$StartupLocation) 

# The powershell runspace that will execute the UI
$xamlGUIPowershell = [PowerShell]::Create().AddScript({  
	
        Set-Location $StartupLocation
        [System.IO.Directory]::SetCurrentDirectory($StartupLocation)

        # Load assemblies
        Add-Type -assemblyName PresentationFramework
        Add-Type -assemblyName PresentationCore
        Add-Type -assemblyName WindowsBase
        Add-Type -assemblyName System.Windows.Forms
        
        # Main UI file
        $MainUIFile = '.\UI\MainWindow.xaml'

        [xml]$xaml = Get-Content $MainUIFile
        #$xaml.InnerXml
        $reader = (New-Object System.Xml.XmlNodeReader $xaml)
        $xamlGUI.Window =[Windows.Markup.XamlReader]::Load( $reader )

        #  Get the named controls
        foreach ($Name in ($xaml | Select-Xml '//*/@Name' | foreach { $_.Node.Value})) {            
           $xamlGUI."Control_$Name" = $xamlGUI.Window.FindName($Name)         
        } 

		
		# Import the module with UI Events for the xamlGUI
        Import-Module -Name '.\Modules\Invoke-UIEvents.psm1'

        # Hashtable to synchronize data transfer between UI and runspaces
        # Create the cancellation key 
        $rsDataTransfer = [hashtable]::Synchronized(@{})
        $rsDataTransfer.CancelScript = $false
      
        # Initialize the UI events
        Initialize-UIEvents

        if (([System.Security.Principal.WindowsPrincipal] [System.Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([System.Security.Principal.WindowsBuiltInRole] "Administrator")) {                        $xamlGUI.Window.Title =  ("{0} - running as Administrative user {1}") -f $xamlGUI.Window.Title, [System.Security.Principal.WindowsIdentity]::GetCurrent().Name        }        else {                        $xamlGUI.Window.Title =  ("{0} - running as User {1}") -f $xamlGUI.Window.Title, [System.Security.Principal.WindowsIdentity]::GetCurrent().Name        }
        

        $xamlGUI.Window.TopMost = $true
        $xamlGUI.Window.ShowDialog() | Out-Null
        $xamlGUI.Error = $Error
    
 
})


$xamlGUIPowershell.Runspace = $xamlGUIRunspace
$xamlGUIAsyncHandle = $xamlGUIPowershell.BeginInvoke()
$xamlGUIPowershell.EndInvoke($xamlGUIAsyncHandle)

if ($xamlGUI.Error -ne $null) {
    Write-Host $xamlGUI.Error
	
}

Remove-Variable xamlGUI

$xamlGUIPowershell.Dispose()
$xamlGUIRunspace.Close() 
