# Purpose: FindIe7 — General-purpose PowerShell utilities.
gwmi -query "select name,version from CIM_Datafile where name='c:\\program files\\internet explorer\\iexplore.exe' and version like '7%'"
