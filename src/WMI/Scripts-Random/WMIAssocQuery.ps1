# Purpose: WMIAssocQuery — PowerShell automation.
gwmi -query "ASSOCIATORS OF {Win32_Group.Domain='lisbon',Name='Administrators'}"