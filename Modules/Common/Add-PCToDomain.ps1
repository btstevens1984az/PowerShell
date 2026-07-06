# Purpose: Add-PCToDomain — Reusable PowerShell function libraries.
#Run.Bat
#Script for adding computer to domain with new name
#These files should always be ran with admin privileges.
#run.bat is not needed to be ran if you have determined Execution policy which gives you permission to run PowerShell Scripts.
#Before running run.bat change path of powershell script (line 2 @ run.bat) to location of AddToDomain.ps1
Function Add-PCToDomain {
Write-Host "Script for adding computer to domain with new name"

$username = Read-Host -Prompt 'Write new computer name'
$domain = Read-Host -Prompt 'Write desired domain'

Add-Computer 83.100.133.204 Get-Credential -DomainName $domain -NewName $name

Write-Host "Finished"
}