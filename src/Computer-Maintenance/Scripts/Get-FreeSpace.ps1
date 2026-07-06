# Purpose: Get-FreeSpace — Routine computer maintenance and cleanup.
Function Get-FreeSpace
{
	Write-Host -Object "Enumerating logical drives... " -NoNewline
	$Volumes = Get-WmiObject -Class Win32_Volume
	Write-Host -Object "Done." -ForegroundColor Green
	Write-Host

	Write-Host -Object "Results:"
	$Volumes | ForEach-Object `
	{
		$Capacity = [Double] ($_.Capacity)
		$Label = $_.Label
		$FreeSpace = [Double] ($_.FreeSpace)
		$FreeSpaceReadable = $FreeSpace
		$FreeSpaceReadableUnit = " bytes"
		$ResultTextColour = [ConsoleColor]::Green

		if ($FreeSpaceReadable / 1024 -ge 1)
		{
			$FreeSpaceReadable /= 1024
			$FreeSpaceReadableUnit = "kB"
		}
		if ($FreeSpaceReadable / 1024 -ge 1)
		{
			$FreeSpaceReadable /= 1024
			$FreeSpaceReadableUnit = "MB"
		}
		if ($FreeSpaceReadable / 1024 -ge 1)
		{
			$FreeSpaceReadable /= 1024
			$FreeSpaceReadableUnit = "GB"
		}
		if ($FreeSpaceReadable / 1024 -ge 1)
		{
			$FreeSpaceReadable /= 1024
			$FreeSpaceReadableUnit = "TB"
		}
		if ($FreeSpaceReadable / 1024 -ge 1)
		{
			$FreeSpaceReadable /= 1024
			$FreeSpaceReadableUnit = "PB"
		}
		if ($FreeSpaceReadable / 1024 -ge 1)
		{
			$FreeSpaceReadable /= 1024
			$FreeSpaceReadableUnit = "EB"
		}
		if ($FreeSpaceReadable / 1024 -ge 1)
		{
			$FreeSpaceReadable /= 1024
			$FreeSpaceReadableUnit = "ZB"
		}
		if ($FreeSpaceReadable / 1024 -ge 1)
		{
			$FreeSpaceReadable /= 1024
			$FreeSpaceReadableUnit = "YB"
		}

		Write-Host -Object "$([Char] 0x2022) Free space available on " -NoNewline
		Write-Host -Object $_.Name -ForegroundColor Cyan -NoNewline
		if (-not ([Object]::ReferenceEquals($Label, $NULL)))
		{
			Write-Host -Object " (labelled " -NoNewline
			Write-Host -Object "`"$Label`"" -ForegroundColor Cyan -NoNewline
			Write-Host -Object ")" -NoNewline
		}
		Write-Host -Object ": " -NoNewline
		if ($Capacity -eq 0)
		{
			Write-Host -Object "(zero-capacity device)" -ForegroundColor Gray
		}
		else
		{
			$FreeSpacePercentage = [Math]::Round($FreeSpace / $Capacity * 100)
			
			if ($FreeSpacePercentage -lt 50)
			{
				$ResultTextColour = [ConsoleColor]::Yellow
			}
			if ($FreeSpacePercentage -lt 25)
			{
				$ResultTextColour = [ConsoleColor]::Red
			}	

			Write-Host -Object "$FreeSpacePercentage% ($("{0:g3}" -f $FreeSpaceReadable)$FreeSpaceReadableUnit)" -ForegroundColor $ResultTextColour
		}
	}
}