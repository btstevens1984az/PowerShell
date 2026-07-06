# Purpose: PrintWebPages — General-purpose PowerShell utilities.

#text file of urls to load and print
param($inputFile = "C:\temp\testurls.txt")

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

Get-Content $inputFile | Print-WebPage
