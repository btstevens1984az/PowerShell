# Purpose: Enable-WinRmRemotely — Network diagnostics, DNS, DHCP, and connectivity.
Function Enable-WinRmRemotely {
# Enables Powershell Remoting
Param ([Parameter(Mandatory=$true)]
[System.String[]]$Computer)
ForEach ($comp in $computer ) {
    Start-Process -Filepath "U:\PSTools\psexec.exe" -Argumentlist "\\$comp -h -d winrm.cmd quickconfig -q" -Credential "$comp\dtadmin"
	Write-Host "Enabling WINRM Quickconfig" -ForegroundColor Green
	Write-Host "Waiting for 60 Seconds......." -ForegroundColor Yellow
	Start-Sleep -Seconds 60 -Verbose	
    Start-Process -Filepath "U:\PSTools\psexec.exe" -Argumentlist "\\$comp -h -d powershell.exe enable-psremoting -force" -Credential "$comp\dtadmin"
	Write-Host "Enabling PSRemoting" -ForegroundColor Green
    Start-Process -Filepath "U:\PSTools\psexec.exe" -Argumentlist "\\$comp -h -d powershell.exe set-executionpolicy RemoteSigned -force" -Credential "$comp\dtadmin"
	Write-Host "Enabling Execution Policy" -ForegroundColor Green	
    Test-Wsman -ComputerName $comp
}
}