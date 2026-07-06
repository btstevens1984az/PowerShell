# Purpose: BadGetRandomObject — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE: 12/22/2008
#
# KEYWORDS: system.random, array, for next
#
# COMMENTS: This script selects a certain number of
# items from an input array in a random fashion.
# uses the system.random .net framework class
# Using a specific seed value, the random number is 
# the same. If you want your own seed value, then you
# need to create a function that will use random types of
# events to generate the seed. Such things like memory
# consumption, amount of paging, processor utilization
# number of running processes, running services, etc.
# time of day, anything that would be likely to generate
# a random number.
# 
# ------------------------------------------------------------------------
Function GetRandomObject($in,$count,$seed)
{
 $rnd = New-Object system.random($seed)
 for($i = 1 ; $i -le $count; $i ++)
 {
  $in[$rnd.Next(1,$a.length)]
 } #end for
} #end GetRandomObject

# *** entry point ***
$a = 1,2,3,4,5,6,7,8,9
$count = 3
GetRandomObject -in $a -count $count -seed 5