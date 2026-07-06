# Purpose: GetLast UpdatesInstalledFor90Days — General-purpose PowerShell utilities.


# get updates installed in the last 3 months
Get-CimInstance -Class win32_quickfixengineering | Where-Object { $_.InstalledOn -gt (Get-Date).AddMonths(-3) }


