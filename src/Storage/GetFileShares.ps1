# Purpose: GetFileShares — Storage management and disk operations.
Get-WmiObject win32_share -Filter "type = '0' AND description = ''"