# Purpose: MISC-TaskSequenceFail — General-purpose PowerShell utilities.

#### Check provisioning state is false.
HKEY_LOCAL_MACHINE\Software\Microsoft\SMS\Mobile Client\Software Distribution\State 


sc config smstsmgr demand= winmgmt/ccmexec
sc config smstsmgr start= demand
net start smstsmgr