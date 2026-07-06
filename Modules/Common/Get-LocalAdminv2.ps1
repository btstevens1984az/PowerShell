# Purpose: Get-LocalAdminv2 — Reusable PowerShell function libraries.
Function Get-LocalAdminv2 {

invoke-command {
$members = net localgroup administrators | 
 where {$_ -AND $_ -notmatch "command completed successfully"} | 
 select -skip 4
New-Object PSObject -Property @{
 Computername = $env:COMPUTERNAME
 Group = "Administrators"
 Members=$members
 }
} -computername (Get-ADComputer -Filter * -SearchBase "$searchbase" | Select-Object -expand Name)  -HideComputerName | 
Select * -ExcludeProperty RunspaceID | Select-Object Computername,Group,Members | Sort-Object computername | Export-Csv $path
}