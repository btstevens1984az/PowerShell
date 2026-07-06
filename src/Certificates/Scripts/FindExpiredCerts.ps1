# Purpose: FindExpiredCerts — PKI and certificate lifecycle operations.
#$computers = Get-Content $servers.txt
$daysfromNow = 5
$throttle = 32
$computers = "dc4","vmhost5"

$command = {
	$Expiredcerts = Get-ChildItem 'cert:\LocalMachine\root' -Recurse| where {$_.gettype().fullname -eq "System.Security.Cryptography.X509Certificates.X509Certificate2"} |
	Where-Object {$_.notafter -lt ((Get-Date).adddays($daysfromNow))}
	if ($Expiredcerts)
	{ 
		$objs = $Expiredcerts |  select FriendlyName,NotAfter,Thumbprint
		$objs
	}
	
}

$results = Invoke-Command -ScriptBlock $command -ComputerName $computers -ThrottleLimit $throttle
$results | select-object @{name='Computer';expression={$_.PSComputerName}},FriendlyName,NotAfter,Thumbprint | Out-GridView
