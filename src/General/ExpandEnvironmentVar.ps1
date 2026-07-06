Function Expand-EnvironmentString
{
<#
.Synopsis
   Expands/resolves environment variable stings like %computername%
.DESCRIPTION
   Expands/resolves environment variable stings like %computername%
.PARAMETER  Path
    Specify a string with an environment variable in the format of %var%\restof\Path
.EXAMPLE
   PS C:\Expand-EnvironmentString -path "%SystemDrive%\inetpub\logs\LogFiles"
   C:\inetpub\logs\LogFiles
.EXAMPLE
   PS C:\ "%SystemDrive%\inetpub\logs\LogFiles" | Expand-EnvironmentString
   C:\inetpub\logs\LogFiles
.INPUTS
   A string with an %envVar%
.OUTPUTS
   The same string inputed with environment variables expanded.
#>  
    param(
    [parameter( Mandatory=$True,
                    Position = 0,
                    HelpMessage="A string with an %envVar%",
                    ValueFromPipeline=$True, 
	                ValueFromPipelineByPropertyName=$True)]
    [string]$Path)
    process
    {    
    (New-object -ComObject "Wscript.Shell").expandEnvironmentStrings($Path)
    }
}