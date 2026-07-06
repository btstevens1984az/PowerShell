# Purpose: GetGroupPolicyProcessingErrors — Active Directory user, group, and domain administration.
#GetGroupPolicyProcessingError.ps1
Get-Event -LogName *group* | 
Where-Object { $_.id -eq 7001 }  | 
Sort-Object -Property timecreated -descending
