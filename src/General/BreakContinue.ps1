# Purpose: BreakContinue — General-purpose PowerShell utilities.
#BreakContinue.ps1

$i=0
foreach ($x in 1..100) {
  $i += $x;
  if ($i % 5) { "Jump to end"; continue}
  $i
  if ($i -gt 1770) {"I'm Out!"; break}
}

write-output "Note: Continue jumps to the bottom of the loop."
write-output "Note: Break exits the loop completely and the next"
write-output "      section of the script will then execute."

