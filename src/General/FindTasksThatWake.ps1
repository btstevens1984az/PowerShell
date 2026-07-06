# Purpose: FindTasksThatWake — General-purpose PowerShell utilities.
#find all tasks configured to wake computer from sleep
#http://archive.msdn.microsoft.com/PowerShellPack
Import-Module TaskScheduler

$tasks = Get-ScheduledTask -recurse

$results = $tasks | ForEach-Object { 

	[xml]$tempxml= $_.xml

	If ($tempxml.task.settings.waketorun -eq $true)
	{
		$_ | select Name,LastRunTime,Path,@{name="WaketoRun";Expression={$true}}

	}
}

$results | Out-GridView