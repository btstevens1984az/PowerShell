# Purpose: MISC-Netsh — General-purpose PowerShell utilities.
#   James Wylde

winrm quickconfig

netsh advfirewall monitor show consec verbose > c:\temp\output.txt
netsh advfirewall monitor show currentprofile
netsh advfirewall set allprofiles state off

netsh winhttp reset proxy

netsh firewall set opmode mode=DISABLE

netsh interface set interface "Ethernet" disabled

netsh advfirewall firewall add rule dir=in name ="WMI" program=%systemroot%\system32\svchost.exe service=winmgmt action = allow protocol=TCP localport=any

netsh advfirewall firewall add rule dir=in name=”RPC” action = allow protocol=tcp localport=135

netsh advfirewall firewall add rule dir=in name="SMB" action = allow protocol=tcp localport=445

netsh advfirewall firewall add rule name=”SMB” dir=in action=allow protocol=tcp localport=445

netsh int ipv4 set dynamicport tcp start=1024 num=5000
netsh int ipv4 set dynamicport tcp start=49152 num=65535
netsh int ipv4 show dynamicport tcp #verify

netsh advfirewall firewall add rule name="GPUPDATE" protocol=TCP dir=in localport=445 action=allow
netsh advfirewall firewall add rule name="GPUPDATE" protocol=TCP dir=in localport=135 action=allow
netsh advfirewall set service remoteadmin

netsh advfirewall firewall add rule name="GPUPDATE" protocol=TCP dir=in localport=445 action=allow
netsh advfirewall firewall add rule name="GPUPDATE" protocol=TCP dir=in localport=135 action=allow
netsh advfirewall set service remoteadmin
