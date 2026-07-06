# Purpose: CheckSnapin — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE: 12/14/2008
#
# KEYWORDS: Get-pssnapin, if, else
#
# COMMENTS: This script checks to see if a snapin 
# is either loaded or running.
#
#
#
# ------------------------------------------------------------------------
function CheckSnapin($name)
{
 if(!(Get-PSSnapin | 
     Where-Object { $_.name -eq $name }))
  { 
    if(!(Get-PSSnapin -registered | 
          Where-Object { $_.name -eq $name }))
      { 
        "$name is not registered. Exiting script."
        exit
     } #end if registered
   ELSE
     {
       add-psSnapin -name $name 
     } #end else registered
  } #end if not get-pssnapin
 ELSE
  { "$name cmdlets already loaded" }
} #end CheckSnapin

CheckSnapin("pscx")