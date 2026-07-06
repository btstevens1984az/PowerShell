# Purpose: TestWMItrap — General-purpose PowerShell utilities.
trap
{
$_ >> errorlog.txt
continue
}
function TestWMI
{
param($computer="localhost")
trap 
{
	Write-Host "Error connecting to $computer"
	#$_ | Format-List *
	$computer >> errorcomputers.txt
	break
	
}

$results = Get-WmiObject Win32_operatingSystem -ComputerName $computer -ErrorAction stop
Write-Host "Successfully connected to $($results.__Server)"


}

testWMI "localhost"
testWMI "38.182.114.129"
testWMI "localhost"