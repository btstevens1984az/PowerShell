# Purpose: 2-4 UsingStatement — General-purpose PowerShell utilities.

using assembly "System.speech"  #Will load the assembly
# Alternative to using
# Add-Type -AssemblyName "System.Speech"
# or the depricated LoadwithpartialName
# [System.Reflection.Assembly]::LoadWithPartialName("System.Speech")
# Using must occur before other statements in a script

#This will allow us to omit the namespace when specifying a class in that namespace.
using namespace "System.Speech.synthesis" 

#will load the module, could alternatively using #requires -module or import-module
using module DnsClient 
Get-Module dnsclient #DNSClient will be loaded from the using module statement.

function Speak-String
{
    param([string]$InputObject="test",
    [validaterange(-10,10)]
    [int]$Rate=0)
    #using namespace "System.Speech.synthesis"
    #before using namespace you would need to type the full classname
    #$speech = New-object system.speech.synthesis.speechsynthesizer
    $speech = New-object speechsynthesizer
    $speech.Rate = $rate
    $speech.Speak($inputObject)

}
Speak-String "Using, the using stamement in Powershell version 5" 



#list out directives
[Enum]::GetNames('System.Management.Automation.Language.UsingStatementKind')

#notes
#Using statements must be the first statements in a Powershell script.

