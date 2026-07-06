# Purpose: Get-ISEHost — General-purpose PowerShell utilities.
﻿Function Get-ISEHost
{
 <#
 .Synopsis
 Determines if you are running in the Windows PowerShell ISE
 .Description
 This function determines if you are running in the Windows Powershell
 ISE by querying the $ExecutionContext automatic variable.
 .Example
 Get-ISEHost
 Prints out True if runing inside the ISE, False if run in console
 .Example
 if(Get-ISEHost) { "Using the ISE" }
 Prints out Using the ISE when run inside the ISE, otherwise nothing
 .Inputs
 None
 .Outputs
 [Boolean]
 Name: Get-ISEHost
 Book: Windows PowerShell Best Practices, Microsoft Press, 2009
 Version: 1.0
 Date: 4/5/2009
 .Link
 about_Automatic_variables
 Http://www.ScriptingGuys.Com
 #>
 $ExecutionContext.Host.name -match "ISE Host$"
} #end Get-ISEHost

