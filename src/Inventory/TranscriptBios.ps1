# Purpose: TranscriptBios — Hardware and software inventory collection.
# ------------------------------------------------------------------------
# DATE: 7/25/2009
#
# KEYWORDS: Get-WmiObject, Win32_bios, Start-Transcript
#
# COMMENTS: This script uses the Start-Transcript cmdlet 
# to produce a log of script results. 
#
#Requires -version 2.0
# ------------------------------------------------------------------------
Param(
 [Parameter(Mandatory=$true)]
 [string]$path,
 [string]$computer = $env:computername
)#end param

# *** Functions ***

Function Get-Bios($computer)
{
 "Calling function $($myInvocation.InvocationName)"
 Get-WmiObject -class win32_bios -computer $computer
}#end function Get-Bios

# *** Entry point to script ***

Start-Transcript -path $path
"Starting $($myInvocation.InvocationName) at $(Get-Date)"
 
Get-Bios -computer $computer
Stop-Transcript 
