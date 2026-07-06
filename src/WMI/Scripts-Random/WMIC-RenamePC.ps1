# Purpose: WMIC-RenamePC — PowerShell automation.
cmd /c "wmic computersystem where name='%computername%' call rename name='NEW NAME'"