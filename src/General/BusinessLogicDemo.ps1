# Purpose: BusinessLogicDemo — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE: 2/8/2009
#
# KEYWORDS: function, business logic, best practice
#
# COMMENTS: This script demos using a function for
# business logic. 
#
#
# Windows PowerShell Best Practices
# ------------------------------------------------------------------------

Function Get-Discount([double]$rate,[int]$total)
{
  $rate * $total
} #end Get-Discount

$total = 100
$rate = .05
$discount = Get-Discount -rate $rate -total $total
"Total: $total"
"Discount: $discount"
"Your Total: $($total-$discount)"