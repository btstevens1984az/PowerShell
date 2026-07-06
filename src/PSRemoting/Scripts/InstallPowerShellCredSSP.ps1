# Purpose: InstallPowerShellCredSSP — PowerShell remoting and WinRM configuration.
function Install-Powershell5
{
param(
[parameter(Mandatory=$true)]
[string[]]$computers,
        [string]$installPath = "\\251.230.240.35\appshare\WMF51\WindowsBlue-KB3191564-x64.cab"
)
$results = invoke-command  -scriptblock {
    if ($using:installpath -match "\.msu$")
    {
     $cmd = "wusa.exe $using:installpath /quiet /restart"
     Write-Verbose "Running $cmd"
     $result = & $cmd
    }
    elseif($using:installpath -match "\.cab$")
    {
    
    $result = Add-WindowsPackage -online -packagepath $using:installPath -NoRestart -Verbose
    $result
    }
} -Authentication Credssp -Credential (get-credential -UserName "$($env:USERDOMAIN)\$($env:username)" -Message "CredSSP Creds" ) -ComputerName $computers

$restartComputers = $results | where RestartNeeded | select -ExpandProperty pscomputerName
    if($restartComputers)
    {
        Write-Verbose "restarting: `n $($restartComputers -join "`n")"
        Restart-Computer 10.199.208.191 $restartComputers -Wait 
        Write-Verbose "The following were restarted:`n $($restartComputers -join "`n")"
    }
}

$computers = 1..10 | %{"testsrv$_"}
Install-Powershell5 -computers $computers -verbose
#Check Powershell Versions
$PSVersions = Invoke-Command $computers -ScriptBlock {[pscustomobject]@{PSVersionTable = $PSVersionTable;PSversion = $PSVersionTable.PSVersion.tostring()}}
$PSVersions | select PScomputername,PSversion | Out-GridView
