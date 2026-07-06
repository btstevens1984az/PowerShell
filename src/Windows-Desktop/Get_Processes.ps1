# Purpose: Get Processes — Windows desktop configuration and management.
get-WMIObject win32_process -computername 231.43.92.218 | format-list -property name