# Purpose: Export-XML — Network diagnostics, DNS, DHCP, and connectivity.
Function Export-XML
{
 <#
   .Synopsis
     Returns XML representation of object
   .Description
     This command creates an XML representation of an object
   .Example
     Get-Service -name ALG | Export-XML
     This command obtains an instance of the ALG service and 
     displays an XML representation of the service object
   .Example
     Get-WmiObject -class Win32_Bios | Export-XML
     This command obtains an instance of the Win32_Bios WMI 
     object and displays an XML representation of the WMI object
   .OutPuts
     XML
    NAME:      Export-XML
   .Link
     about_functions_advanced
     about_functions_advanced_methods
     about_functions_advanced_parameters
     about_types
 #Requires -Version 2.0
 #>
 [CmdletBinding()]
 Param(
       [Parameter(Position=0,
        Mandatory=$true,
        ValueFromPipeline=$true)]
        [object]$object
 )
@"
<Object>
  $(    
    foreach ($p in $object |Get-Member -type *Property)
     {
      $Name  = $p.Name
      $Value = $object.$Name    
   @"
  `t<$Name>$Value</$Name>`n
"@
     } #foreach property
   )
</Object>
"@
} #end Export-XML

