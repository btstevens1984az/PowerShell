# Purpose: splat — General-purpose PowerShell utilities.

$splat = @{class="win32_process";filter="name = 'powershell.exe'"}
gwmi @splat

#have to use $input and -inputobject

$test = "winlogon","Powershell"
$jobs = $test | 
	%{
	$JobParameters = @{
	Name = $_
	ScriptBlock = {Get-Process -Name $_}
	}
	Start-Job @JobParameters
	}


