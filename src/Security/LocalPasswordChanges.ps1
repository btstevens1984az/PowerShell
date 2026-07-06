# Purpose: LocalPasswordChanges — Security auditing and compliance checks.
#https://www.microsoft.com/en-us/download/details.aspx?id=46899
#http://windowsitpro.com/powershell/resetting-local-administrator-password-computers

$computers = Get-Content .\computers.txt
Foreach ($computer in $computers)
{
    Write-Host "Changing password on $computer"
    ([adsi]"WinNT://$computer/administrator").setpassword("sdfjlksdjflksjdflkjs123082384902834!")

}
Write-host "Done changing passwords" -ForegroundColor DarkGreen