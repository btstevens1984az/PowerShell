# Purpose: cmdlineToolsWhichExportToCSV — Network diagnostics, DNS, DHCP, and connectivity.
$drivers = driverquery /FO csv | ConvertFrom-csv
