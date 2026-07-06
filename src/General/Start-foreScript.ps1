# -----------------------------------------------------------------------------------------
# Script: Start-foreScripts.ps1
# Date: April 24, 2015
# Version: 1.0
# Purpose: This script is used to start xamlGUI in a new Powershell process.
#
# Project: foreScript
#
# -----------------------------------------------------------------------------------------
#
# (C) Nigel Thomas, 2015
#
#------------------------------------------------------------------------------------------

#Requires -version 3.0

# Set the working directory to the startup path of the script
$StartupLocation = Split-Path $script:MyInvocation.MyCommand.Path

#$StartupLocation = [System.AppDomain]::CurrentDomain.BaseDirectory.TrimEnd('\')

[System.IO.Directory]::SetCurrentDirectory($StartupLocation)

Set-Location $StartupLocation

Start-Process powershell -Argument '-executionpolicy bypass -noninteractive -noprofile .\Initialize-UI.ps1' -Windowstyle Hidden 
