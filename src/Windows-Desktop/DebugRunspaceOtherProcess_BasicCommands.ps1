# Purpose: DebugRunspaceOtherProcess BasicCommands — Windows desktop configuration and management.
#basic other Process debug commands
Get-PSHostProcessInfo #find processes hosting Powershell
Enter-PSHostProcess    #enter other process         
Get-RunspaceDebug      #discover runspaces                                
Debug-Runspace 1   #attach debugger to runspace