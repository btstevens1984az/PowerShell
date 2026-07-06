# Purpose: Get-PsCmdlet — General-purpose PowerShell utilities.
﻿Function Get-PsCmdlet
{
 <#
 .Synopsis
 Allows you to explore the members of the $psCmdlet automatic variable
 .Description
 This Advanced Function allows you to explore the members of the 
 $psCmdlet automatic variable. This variable only exists within the
 context of an Advanced Function. 
 .Example
 Get-PsCmdlet | gm
 Displays members of System.Management.Automation.PSScriptCmdlet
 .Example
 (Get-PsCmdlet).myinvocation | gm
 Displays member of System.Management.Automation.InvocationInfo
 .Example
 (Get-PsCmdlet).CurrentProviderLocation("FileSystem")
 Displays current working location of FileSystem PSDrive. Ex: c:\temp
 .Outputs
 [string]
 Name: Get-PsCmdlet
 Book: Windows PowerShell Best Practices, Microsoft Press, 2009
 Version: 1.0
 Date: 4/11/2009
 .Link
 Get-Member
 Http://www.ScriptingGuys.Com 
#Requires -Version 2.0
 #>
 [CmdletBinding()]
  Param(
       [Parameter(Position=0,
        Mandatory=$false,
        ValueFromPipeline=$true)]
        [object]$object
        )
 $psCmdlet
}