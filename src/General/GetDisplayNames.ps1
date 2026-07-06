# Purpose: GetDisplayNames — General-purpose PowerShell utilities.
#Queries GC
$Users = Get-Content $PSScriptRoot\users.txt
New-PSDrive -PSProvider ActiveDirectory -Name "GC" -Root "" –Server "contoso.com:3268"
Set-Location GC:
$userData = $users | ForEach-Object{Get-ADUser -Filter {SamAccountName -eq $_} -Properties DisplayName}
$userdata.displayname | out-file $PSScriptRoot\UserDisplaynames.txt
Compare-Object $users $userdata.samaccountname | Select-Object -ExpandProperty inputobject | Out-File $PSScriptRoot\notfound.txt