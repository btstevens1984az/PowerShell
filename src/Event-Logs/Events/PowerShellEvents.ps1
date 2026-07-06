# Purpose: TryCatch — Cross-cutting logging, error handling, and utilities.
$computers = "localhost","bogus123456","localhost"
$ErrorActionPreference = "stop"
$FailedComputers = @()
trap{

 $_ | Format-List * -Force > error.log
 $_ | Export-Clixml .\error.xml
 continue #effectively makes this work like 'on error resume next' for this scope
}
try
{
	#here
	
	foreach ($computer in $computers)
	{
		try{
		$computer
		Get-WmiObject -ComputerName $computer -Class Win32_OperatingSystem
        "No Error on $computer"
		}
	    CATCH [System.Runtime.InteropServices.COMException]
        {
            Write-Verbose "RPC error on: $computer"
            $FailedComputers += $computer

        }
		catch
		{
		 Write-Host "inner caught it"
            # $_ #$_ contains the exception passed to the catch statement
		 $Error.Clear()
		throw $_
		 
		}
		Finally
		{
		"inner finally"
		}
	
	}
	
}
catch
{
 Write-Host "outer Catch"
 $Error.Clear()
 #continue
 
}
Finally
{
"outer finally"
}
throw "test"
"I got here"
Write-Host "Failed Computers:"
$FailedComputers
