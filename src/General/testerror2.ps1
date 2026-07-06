# Purpose: testerror2 — General-purpose PowerShell utilities.
$computernames= "kms","badname","dc4"
$cred = Get-Credential #-UserName "kayloslab\jeff"
foreach ($comp in $computernames)
{
    $Error.Clear()
    try
    {
	    Get-WmiObject Win32_logicaldisk -ComputerName $comp -Credential $cred -ErrorAction stop
	    If ($Error)
	    {
	    #$Error[0] | Format-List * -Force 
        $Error[0] | Select-object *
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
	    Write-Host "Access Denied"
    }
    catch
    {
	    Write-Host "Unexpected Failure"
        $_ | Format-List -Force
	    exit
    }
    finally
    {
	    Write-Host "done"
    }
}