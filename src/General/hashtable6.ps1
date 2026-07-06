# Purpose: hashtable6 — General-purpose PowerShell utilities.
Get-ChildItem C:\Windows | 
  Select-Object Name, CreationTime,  @{Name="Kbytes";Expression={$_.Length / 1Kb}} |
    Format-Table -AutoSize

Get-ChildItem C:\Windows | 
  Select-Object Name, @{Name="Age";Expression={ (((Get-Date) - $_.CreationTime).Days) }} |
    Format-Table -AutoSize

Get-Process csrss | 
   Format-table ProcessName, @{Label="TotalRunningTime"; Expression={(get-date) - $_.StartTime}}
