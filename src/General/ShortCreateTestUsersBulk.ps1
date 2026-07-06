# Purpose: ShortCreateTestUsersBulk — General-purpose PowerShell utilities.
1..1000 | %{New-QADUser -ParentContainer "ou=test,dc=nwtraders,dc=com" -name ("testuser$_")}
#Get-QADUser testuser* | Remove-QADObject 