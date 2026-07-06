# Purpose: Enable-WinRMRemoteComputers — Network diagnostics, DNS, DHCP, and connectivity.
Function Enable-WinRMRemoteComputers {
ForEach ($computer in (Get-Content "C:\Users\$env:USERNAME\Desktop\test.txt"
))
{if(!(Test-Connection -Cn $computer -BufferSize 16 -Count 1 -ea 0 -quiet))
 
{Write-output "Can't Reach $computer" | Out-File 'C:\Temp\PSRemoting_Can_not_Reach.txt' -append}
 
 
else {
 
		Write-Host "Enabling WinRM on" $computer "..." -ForegroundColor cyan
		U:\PSTools\PsExec.exe \\$computer -s powershell Enable-PSRemoting -Force
		if ($LastExitCode -eq 0) {
			U:\PSSTools\PsService.exe \\$computer restart WinRM
			
            $result = winrm id -r:$computer 2>$null			
			if ($LastExitCode -eq 0) {Write-Host 'WinRM successfully enabled!' -ForegroundColor green}
			else {Write-output "WinRM failed to be enabled on $computer" | Out-File 'C:\Temp\PsRemoting_Fails.txt' -append}
}
}
}
}