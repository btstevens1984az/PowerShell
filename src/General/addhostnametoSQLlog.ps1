# Purpose: addhostnametoSQLlog — General-purpose PowerShell utilities.
$results = Import-Clixml test.xml
$filteredresults = $results | ?{$_.text -match "\b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b"}
$finalresults=$filteredresults | %{ 
	$ipaddress = $_.text | 
	Select-String  -Pattern "\b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b" |
	%{$_.matches} | %{$_.value}
	#$ipaddress
	$hostname = [System.Net.Dns]::GetHostByAddress($ipaddress).HostName
	$_ | select-object logdate,text,@{label="hostname";expression={$hostname}}
}
$finalresults | Out-GridView