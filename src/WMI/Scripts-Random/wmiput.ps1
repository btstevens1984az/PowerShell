# Purpose: wmiput — PowerShell automation.
#JD
 gwmi Win32_OperatingSystem | %{$_.description = "test";$_.put()}