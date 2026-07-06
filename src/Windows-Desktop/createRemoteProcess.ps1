# Purpose: createRemoteProcess — Windows desktop configuration and management.
#demo of the [WMICLASS] type accelerator
param($computer=".",$process="notepad.exe")
$wmiProcess = [wmiclass] "\\$computer\root\cimv2:win32_process"
$result =$wmiProcess.Create($process)
if ($result.returnvalue -eq 0)
{"$process launched on $computer successfully"}
else
{"Process not completed sucessfully"}

