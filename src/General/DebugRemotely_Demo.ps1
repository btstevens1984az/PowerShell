# Purpose: DebugRemotely Demo — General-purpose PowerShell utilities.
# Create a Session to localhost
New-PSSession -ComputerName 134.213.133.128
Get-PSSession

# Use Pipelining to Enter-PSSession
Get-PSSession | Enter-PSSession

# Setup a breakpoint in a script and trigger it.
Set-PSBreakpoint -Script C:\temp\testscript.ps1 -Line 2

# Now let's execute the script and see what happens.
C:\PShell\Demos\testscript.ps1 

# Debugging Commands
continue   #Continue running script
detach     #detach debugger from script
quit       #quit script being debugged

Exit-PSSession

#Launch Remote Powershell tab to debug the script on a remote server and open remote script
psedit C:\Pshell\Demos\testscript.ps1