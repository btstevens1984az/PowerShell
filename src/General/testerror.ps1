# Purpose: testerror — General-purpose PowerShell utilities.
param($computernames=@("kms","badname","dc4"))
foreach ($comp in $computernames)
{
    $Error.Clear()
    try
    {
	    Get-WmiObject Win32_logicaldisk -ComputerName $computername -Credential (Get-Credential)
	    If ($Error)
	    {
	    $Error[0] | Format-List * -Force 
	    throw $Error[0]
	    }
        "Success $comp"
    }
    catch [System.Runtime.InteropServices.COMException]
    {
	    Write-host	"Server not online"
	    $Error.Clear()
    }
    catch [System.UnauthorizedAccessException]
    {
	    Write-Host "I caught it"
    }
    catch
    {
	    Write-Host "Unexpected Failure"
	    exit
    }
    finally
    {
	    Write-Host "done"
    }
}