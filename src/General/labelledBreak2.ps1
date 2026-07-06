# Purpose: labelledBreak2 — General-purpose PowerShell utilities.
# in labelled break/continue, 
# the label being referred to can even be a variable, 
# so that you can selectively alter the break-out/continue target
# to be whichever loop-label is desired/required given the current state.

# run as .\labelledBreak2.ps1
#labelledBreak2.ps1
$a=$false
$b=$true
$c=$false

:computer while ($true)
 {
  "computer"
     :process while ($true)
     {
       "process"
           while ($true)
           {
              "inner"
              if ( ((get-date).millisecond) % 5) {$label = "process"} 
              else {$label = "computer"}
              if ((get-random -Max 100) -LT 50) {$a=$true} else {$a=$false}
              if ((get-random -Max 100) -GT 90) {$b=$true} else {$b=$false}
              if ((get-random -Max 100) -GT 90) {$c=$true} else {$c=$false}
              if ($a) {break}
              if ($b) {break $label}
              if ($c) {continue $label}
            }
            "After innermost loop"
      }
      "After 'process' loop"
 }
"After 'computer' loop"

# weird/interesting thing:
# the search for "label" name extends UP the calling stack 
# and will cross function and script boundaries. Even if 
# that means finding the "label" in a calling script that 
# had this function called via its own loop.  Wild!

