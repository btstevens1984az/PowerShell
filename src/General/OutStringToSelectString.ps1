# Purpose: OutStringToSelectString — General-purpose PowerShell utilities.
get-service | out-string -Stream| select-string netlogon