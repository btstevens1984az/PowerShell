# Purpose: Print-WebPage — General-purpose PowerShell utilities.

Function Print-WebPage{
	Begin
	{
		$ie = New-Object -ComObject "InternetExplorer.Application"
	}
	Process
	{
		$ie.navigate($_)
		while ($ie.readystate -ne 4)
		{
			Start-Sleep -Milliseconds 200
		}
		$ie.ExecWB(6,2)
	}
	End
	{		
		#Sleep to prevent closing IE before printing is spooled
		Start-Sleep -Seconds 10
		Write-Host "Finished Printing"
		[void] $ie.quit()
	}
}
