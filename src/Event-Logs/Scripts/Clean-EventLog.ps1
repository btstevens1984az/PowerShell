# Purpose: Clean-EventLog — Windows event log querying and analysis.
Function Clean-EventLog
{
	$EventLogBackupPath = Join-Path -Path $env:windir -ChildPath "Logs\EventLogs"

	Write-Host -Object "Checking for an existing event log archive directory... " -NoNewline
	if (Test-Path -Path $EventLogBackupPath -PathType Container)
	{
		Write-Host -Object "OK." -ForegroundColor Green

		Write-Host -Object "Deleting event log archives older than 90 days: " -NoNewline
		Get-ChildItem -Path (Join-Path -Path $EventLogBackupPath -ChildPath '*.evtx') -Force | Where-Object `
		{
			-not $_.PSIsContainer -and $_.LastWriteTime -lt ([DateTime]::Now - (New-TimeSpan -Days 90))
		} | `
		ForEach-Object `
		{
			try
			{
				Write-Host -Object "$([Char] 0x2022) Deleting " -NoNewline
				Write-Host -Object $_.Name -NoNewline -ForegroundColor Cyan
				Write-Host -Object "... " -NoNewline
				Remove-Item -Path $_.FullName -Force -ErrorAction Stop
				Write-Host -Object "Done." -ForegroundColor Green
			}
			catch
			{
				Write-Host -Object "Failed ($($_.Exception.Message))." -ForegroundColor Red
			}
		}
	}
	else
	{
		Write-Host -Object "Absent." -ForegroundColor Yellow
		Write-Host -Object "Creating an event log archive directory... " -NoNewline
		try
		{
			New-Item -Path $EventLogBackupPath -ItemType Container -Force -ErrorAction Stop > $NULL 2>&1
			Write-Host -Object "OK."
		}
		catch
		{
			Write-Host -Object "Failed ($($_.Exception.Message))."
		}
	}
	Write-Host

	if (Test-Path -Path $EventLogBackupPath -PathType Container)
	{
		$ArchivingTime = [DateTime]::Now
		
		Write-Host -Object "Enumerating event logs... " -NoNewline
		$EventLogs = Get-WmiObject -Class Win32_NTEventLogFile
		Write-Host -Object "Done." -ForegroundColor Green

		$EventLogs | ForEach-Object `
		{
			$ArchiveFileName = "$($_.LogfileName)-$($ArchivingTime.ToFileTimeUtc()).evtx"

			Write-Host -Object "Saving " -NoNewline
			Write-Host -Object $_.LogfileName -NoNewline -ForegroundColor Cyan
			Write-Host -Object " event log to " -NoNewline
			Write-Host -Object $ArchiveFileName -NoNewline -ForegroundColor Cyan
			Write-Host -Object "... " -NoNewline
			$_.BackupEventLog((Join-Path -Path $EventLogBackupPath -ChildPath $ArchiveFileName)) > $NULL 2>&1
			Write-Host -Object "Done." -ForegroundColor Green

			Write-Host -Object "Clearing " -NoNewline
			Write-Host -Object $_.LogfileName -NoNewline -ForegroundColor Cyan
			Write-Host -Object " event log... " -NoNewline
			Clear-EventLog -LogName $_.LogfileName
			Write-Host -Object "Done." -ForegroundColor Green
		}
	}
}
