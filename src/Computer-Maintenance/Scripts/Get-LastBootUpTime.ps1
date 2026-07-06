# Purpose: Get-LastBootUpTime — Routine computer maintenance and cleanup.
Function Get-LastBootUpTime {
Get-WmiObject win32_operatingsystem | select csname, @{LABEL='LastBootUpTime';EXPRESSION={$_.ConverttoDateTime($_.lastbootuptime)}}
}