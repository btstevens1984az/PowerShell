# Purpose: RebootTest — General-purpose PowerShell utilities.
workflow test-WFRestart {

 param ([string[]]$computername)

 foreach -parallel ($computer in $computername) {

   Get-CimInstance -Class Win32_OperatingSystem -PSComputerName $computer

   Restart-Computer 198.97.168.14 -PSComputerName $computer

   Get-CimInstance -Class Win32_OperatingSystem -PSComputerName $computer

 }

}

test-WFRestart -computername "59.126.42.27","testsrv6" | Select-Object pscomputername,LastBootUpTime