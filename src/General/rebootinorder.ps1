# Purpose: rebootinorder — General-purpose PowerShell utilities.
#Reboot Computers From Text File
$cred=Get-Credential -ErrorAction Stop
$computers=Get-Content "d:\temp\CompToRebootInOrder.txt"
[int]$pingCount=2
[int]$timeoutCount=300
[int]$SecWaitBetweenServers = 120
[int]$pingWait=100 #milliseconds
foreach ($computer in $computers)
{
	Restart-Computer 10.199.208.191 $computer -Force -Credential $cred -ErrorAction Stop
	#Ping Check To Continue NOTE: THEN is assumed at the end of line 10
	$count=0
	do
	{
		"Waiting For Computer To Shutdown: $computer"
		$count++
		Start-Sleep -Milliseconds $pingWait
	}
	while ((Test-Connection $computer -Count $pingCount -Quiet)-and $count -le $timeoutCount)
	If ($count -gt $timeoutCount)
	{
		throw ("Error: reached timeout")
	}
	$count=0
	do
	{
		"Waiting For Computer To Wake Up: $computer"
		$count++
		Start-Sleep -Milliseconds $pingWait
	}
	until ((Test-Connection $computer -Count $pingCount -Quiet ) -or $count -gt $timeoutCount)
	If ($count -gt $timeoutCount)
	{
		throw ("Error: reached timeout")
	}
	Start-Sleep $SecWaitBetweenServers
}

"Job Complete"