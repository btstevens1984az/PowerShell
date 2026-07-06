# Purpose: Fix-WindowsDrivers — Windows Update and patch management.

#Traverses through files that are created when you perform any driver changes to a new version of that driver on the Windows side
#The following log files are created when an upgrade is successful:
$GoodLogFile1="C:\Windows\Panther\Setupact.log"
$GoodLogFile2="C:\Windows\panther\setuperr.log"
$GoodLogFile3="C:\Windows\inf\setupapi.app.log"
$GoodLogFile4="C:\Windows\inf\setupapi.dev.log"
$GoodLogFile5="C:\Windows\panther\PreGatherPnPList.log"
$GoodLogFile6="C:\Windows\panther\PostApplyPnPList.log"
$GoodLogFile7="C:\Windows\panther\miglog.xml"

#The following log files are created when an upgrade fails during installation before the computer restarts for the second time:
$BadLogFile1=Get-Content -Path "C:\$Windows.~BT\Sources\panther\setupact.log"
$BadLogfile2=Get-Content -Path "C:\$Windows.~BT\Sources\panther\setupact.log"
$BadLogfile3=Get-Content -Path "C:\$Windows.~BT\Sources\panther\miglog.xml"
$BadLogfile4=Get-Content -Path "C:\Windows\setupapi.log"

#The following log files are created when an upgrade fails during installation after the computer restarts for the second time:
$BadLogFile5=Get-Content -Path "C:\Windows\panther\setupact.log"
$BadLogFile6=Get-Content -Path "C:\Windows\panther\miglog.xml"
$BadLogFile7=Get-Content -Path "C:\Windows\inf\setupapi.app.log"
$BadLogFile8=Get-Content -Path "C:\Windows\inf\setupapi.dev.log"
$BadLogFile9=Get-Content -Path "C:\Windows\panther\PreGatherPnPList.log"
$BadLogFile10=Get-Content -Path "C:\Windows\panther\PostApplyPnPList.log"
$BadLogFile11=Get-Content -Path "C:\Windows\memory.dmp"

#The following log files are created when an upgrade fails, and then you restore the desktop:
$ContingencyLogFile1=Get-Content -Path "C:\$Windows.~BT\Sources\panther\setupact.log"
$ContingencyLogFile2=Get-Content -Path "C:\$Windows.~BT\Sources\panther\miglog.xml"
$ContingencyLogFile3=Get-Content -Path "C:\$Windows.~BT\sources\panther\setupapi\setupapi.dev.log"
$ContingencyLogFile4=Get-Content -Path "C:\$Windows.~BT\sources\panther\setupapi\setupapi.app.log"
$ContingencyLogFile5=Get-Content -Path "C:\Windows\memory.dmp"

#The following log files are created when an upgrade fails, and the installation rollback is initiated:
$ContingencyLogFile6=Get-Content -Path "C:\$Windows.~BT\Sources\Rollback\setupact.log"
$ContingencyLogFile7=Get-Content -Path "C:\$Windows.~BT\Sources\Rollback\setupact.err"

#Finding the Logs that are bigger than 0 MB in size, and getting their Directory and DateCreated TimeStamp
Get-ChildItem -Path "C:\Windows","C:\Windows\Inf","C:\Windows\Panther","C:\Windows\Windowsupdate*.log","C:\$Windows.~BT\Sources\Panther","C:\$Windows.~BT\Sources\Rollback","C:\$Windows.~WS\Sources\Panther","%SystemRoot%\MEMORY.DMP" -Include "BlueBox.log","miglog.xml","Setupapi*.log","Setuperr.log","Setupact.log" -Recurse -Force | Where-Object -Property Length -GT "0" | Select-Object -Property FullName,LastWriteTime -Unique | Out-GridView -Title "Your Drive Error Logs"
Get-Content -Path "C:\Windows\Panther\setupact.log"

#Find the errors quickly
$string='*error*'
$BadLogFile1, $BadLogFile2, $BadLogFile3, $BadLogFile4, $BadLogFile5, $BadLogFile6, $BadLogFile7, $BadLogFile8, $BadLogFile9, $BadLogFile10, $BadLogFile11 | % {Get-Content -Path $_ | Select-String $string -Context 3 -SimpleMatch} | Out-GridView -Title "Your Failed Results"
