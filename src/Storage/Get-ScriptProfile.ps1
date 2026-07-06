#REQUIRES -VERSION 2.0


<#
.Synopsis
    This script will analyze a PowerShell script, primarily
    a v1.0 script and create a script profile.
.Description
    This script will report what parameters are called in the 
    analyzed script, where they are called, what PowerShell 
    commands are executed, what functions are defined internally 
    and if the script is digitally signed.
.Parameter Script
    The path to the .ps1 script file you want to profile
.Parameter Code
    If specified, then the script's code will be displayed
    at the end of the profile

.Example
    PS C:\> c:\scripts\get-scriptprofile foo.ps1 | Out-file FooProfile.txt
    Save the basic script profile to a text file.
.Example
    PS C:\> c:\scripts\get-scriptprofile foo.ps1 -code
    Display the script profile along with the code from
    foo.ps1
.Example
    PS C:\scripts> dir test*.ps1 | .\get-scriptprofile.ps1
    Build a script profile for every PowerShell script that
    begins with Test.
.Inputs
    Accepts strings as pipelined input
.Outputs
    [object]   
           
.Link
   Get-Command
   Get-AuthenticodeSignature
   About_Functions
   About_Parameters
   About_Scripts
      
 VERSION:   1.0

 THIS IS A WORK IN PROGRESS...ESPECIALLY WITH POWERSHELL V2.0
 SCRIPTS

 DISCLAIMER AND WARNING:
    THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY
    KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
    IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
    TEST THOROUGHLY IN A NON-PRODUCTION ENVIRONMENT. IF YOU DON'T KNOW WHAT THIS
    SCRIPT WILL DO...DO NOT RUN IT!

 Microsoft PowerShell Source File -- Created with SAPIEN Technologies PrimalScript 2009

#>

[CmdletBinding()]

#define the parameters
param (
    [Parameter(
     ValueFromPipeline=$True,
     Position=0,
     Mandatory=$True,
     HelpMessage="Enter a the path and name to a PowerShell script")] 
     [String[]]$script,
     
    [Parameter(
     ValueFromPipeline=$False,
     Position=1,
     Mandatory=$False,
     HelpMessage="Specify if you want to see the script's code.")] 
     [switch]$code
     )



Begin {
    #get command information
    $cmdHash=@{}
    Get-Command -CommandType Alias,Function,Filter,ExternalScript,Cmdlet |
     foreach {
      $cmdHash.add($_.name,$_.CommandType)
      }
} #end Begin Scriptblock

Process {
    If (-Not (Test-Path $script)) {
      return "Cannot find $script."
    }
    
    $fullname=(Get-Item $script).Fullname
    $data=Get-Command $fullname
    $content=($data.scriptContents).Split("`n")
    #strip out commented lines
    $content=$content | where {$_ -notmatch "^\s*#"}
    
    write `n
    write $fullname.ToUpper()
    write ("Digital Signature: {0}" -f (Get-AuthenticodeSignature $script).status)
    
    write "`nParameters"
    write "----------"
    
    $params=@()
    $data.parameters.values  | foreach {
     $params+=$_.name
     $_ | select Name,ParameterType
     }
    
    write "`nParameter usage"
    write "---------------"
    $content | foreach {
     $line=$_
     $params | foreach {
       if ($_ -eq "?") {
          $key="\$_"
          [regex]$r="$key"
       }
       else {
          $key="$_"
         [regex]$r="\b$key\b"
       }
       if ($line -match $r) {
         write $line.Trim()
       } #end if
     } #end foreach param
     #select only unique lines to weed out
     #multiple matches for the same line
    } | select -Unique #end foreach line
    
    write "`nInternally Defined Functions"
    write "----------------------------"
    $content | foreach {
      if ($_ -match "function \w*.\w*") {$matches.values}
    }
    
    write "`nInvoked Commands"
    write "----------------"
    $content | foreach {
     $line=$_
     $cmdHash.keys | foreach {
     #escape the ? which is a special regex character
       if ($_ -eq "?") {
          $key="\$_"
          [regex]$r="$key"
       }
       else {
          $key="$_"
         [regex]$r="\b$key\b"
       }
       if ($line -match $r) {
         write $line.Trim()
       } #end if
     } #end foreach key
     
    } | select -unique #end foreach content line
    
    If ($code) {
    #write script contents if -code was specified
        write "`nScript Contents"
        write "---------------"
        write $data.scriptcontents
    }
} #end Process script block

End {
 #this isn't used
} #end End script block

#end of script

