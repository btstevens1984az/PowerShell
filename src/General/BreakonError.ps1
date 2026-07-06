# Purpose: BreakonError — General-purpose PowerShell utilities.
Set-PSBreakpoint -Variable stacktrace -Mode Write

1..50 | ForEach-Object {

write-error $_ -ErrorAction stop

}