# Purpose: labelledBreak1 — General-purpose PowerShell utilities.
# flow control within NESTED While/For loops that might need to exit to the 
# outer layer can get rather complicated. Yes, this does crop up occasionally!
# Soo.. PowerShell brings in the concept of "labelled loops", to allow a break 
# specifying the outer loop to break out of. Yes, I am in some loop deep within
# a nest, and yes I can say  break out of the whole mess and go of the end of 
# "labelled loop". This (when you need it) is a life-saver!
# NOTE: the label only applies to a LOOP construct. (while/for/do until/etc.)
#       You cannot use labels like this anywhere else.

# run as .\labelledBreak1.ps1
#labelledBreak1.ps1
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
              if ((get-random -Max 100) -LT 50) {$a=$true} else {$a=$false}
              if ((get-random -Max 100) -GT 90) {$b=$true} else {$b=$false}
              if ((get-random -Max 100) -GT 90) {$c=$true} else {$c=$false}
              if ($a) {break}
              if ($b) {break computer}
              if ($c) {break process}
            }
            "After innermost loop"
      }
      "After 'process' loop"
}
"After 'computer' loop"

