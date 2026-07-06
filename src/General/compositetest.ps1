# Purpose: compositetest — General-purpose PowerShell utilities.
enum ServiceState
{
    Running
    Stopped 
}

configuration CombineConfigs
{
    param([string[]]$computerName,
          [string[]]$Names,
          [ServiceState]$State
    )
    Import-DscResource -ModuleName Myconfigs 
    node $computerName {
    MyServiceConfig Spooler{
        names = $Names
        state = $State
    }
    }

}

configuration CombineConfigs2
{

    Import-DscResource -ModuleName Myconfigs 
    node localhost {
    MyFolderConfig Test1
    {
        Paths = "c:\temp2","c:\temp3"
        Ensure = "Present"


    }
    }

}
$comp = "testsrv9"
CombineConfigs -computerName $comp -Names netlogon,bits -State Running
#start-dscconfiguration -Path .\combineConfigs -computerName $comp -wait -verbose
Get-service bits,netlogon -computername $comp