# Purpose: EventlogsPSremote — System monitoring and alerting.
$servers = "201.72.64.23","dccore"
$events = Invoke-Command -ComputerName $servers -ScriptBlock {Get-EventLog -LogName system | ?{$_.eventid -eq 6009}} -ThrottleLimit 50