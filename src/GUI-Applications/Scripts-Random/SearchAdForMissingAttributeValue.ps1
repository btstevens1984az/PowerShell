# Purpose: SearchAdForMissingAttributeValue — PowerShell automation.
﻿# -----------------------------------------------------------------------------
# 
# SearchAdForMissingAttributeValue.ps1
# Ed Wilson, Msft, 11/1/2008
#
# Uses the adsiSearcher type accelerator to search ad
# uses findall method to return values
# uses an LDAP dialect type of search syntax
# uses the -begin, -process and -end parameters of the foreach-object cmdlet
# this allows pre-processing to display a head for the output, and the process
# obtains the data, and then end displays our summary text.
# This is one cmdlet, and therefore we need to use the ` for line continuation
#
# -----------------------------------------------------------------------------

#Requires -version 2.0
$SearchAttribute = "HomeDirectory"
$DisplayAttribute = "DistinguishedName"
$SearchRoot = "ou=testou,dc=nwtraders,dc=com"
$filter = "ObjectCategory=user"
$ds = [adsiSearcher]$filter
$ds.SearchRoot = "LDAP://$SearchRoot"
$ds.findAll() | 
ForEach-Object `
  -BEGIN { $i = 0 ; "$filter missing $SearchAttribute value" } `
  -PROCESS `
   {
     IF([string]::isNullOrEmpty($_.properties.item($SearchAttribute)))
      {
       $_.Properties.item($DisplayAttribute)
       $i++
      } # end if
   } `
  -END { "There are $i missing the $SearchAttribute value" }