# Purpose: GetRandomObject — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE: 12/22/2008
#
# KEYWORDS: system.random, array, for next
#
# COMMENTS: This script selects a certain number of
# items from an input array in a random fashion.
# uses the system.random .net framework class
#
#
# ------------------------------------------------------------------------
Function GetRandomObject($in,$count)
{
 $rnd = New-Object system.random
 for($i = 1 ; $i -le $count; $i ++)
 {
  $in[$rnd.Next(1,$a.length)]
 } #end for
} #end GetRandomObject

# *** entry point ***
$a = 1,2,3,4,5,6,7,8,9
$count = 3
GetRandomObject -in $a -count $count