# Purpose: RestartRemote — General-purpose PowerShell utilities.
#http://blogs.technet.com/b/heyscriptingguy/archive/2013/01/23/powershell-workflows-restarting-the-computer.aspx
workflow test-restart {

 param ([string[]]$computernames)

 foreach -parallel ($computer in $computernames) {

   Get-WmiObject -Class Win32_ComputerSystem -PSComputerName $computer
   Restart-Computer 198.97.168.14 -PSComputerName $computer
   Get-WmiObject -Class Win32_OperatingSystem -PSComputerName $computer

 }

}

$computers = "kms","pkiroot"
test-restart -computernames $computers