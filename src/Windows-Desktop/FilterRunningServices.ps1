# Purpose: FilterRunningServices — Windows desktop configuration and management.
Filter Running-Service
{ 
 $_ | 
 Where-Object { $_.status -eq 'running'}
}

Get-Service | Running-Service | Format-Table -Property Name, DisplayName -AutoSize