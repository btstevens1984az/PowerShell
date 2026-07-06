# Purpose: Get-PropertyValuesFilter — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE: 2/14/2009
#
# KEYWORDS: Filter, WMI, Get-WmiObject
#
# COMMENTS: This is a filter that can be used with WMI
# it will display only properties from a class that hava a value.
# You call it thusly:
# Get-WmiObject -class classname | Get-PropertyValues
# 
# Windows PowerShell Best Practices
# ------------------------------------------------------------------------
Filter Get-PropertyValues 
{ 
  $_ | 
  Foreach-Object `
    {  
      $_.psobject.properties | 
      Foreach-Object `
       { 
        If($_.value)
         { 
           If ($_.name -match "__"){}
           ELSE
             { 
               Write-Host "$($_.name)`t`t $($_.value)" 
             } #end ELSE 
          } #end if $_.value  
       } #end Foreach-Object
    } # end ForEach -Object
} # end Get-PropertyValues filter

# gwmi -class win32_networkadapter | Get-PropertyValues