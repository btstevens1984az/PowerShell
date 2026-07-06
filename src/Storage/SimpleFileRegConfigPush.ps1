# Purpose: SimpleFileRegConfigPush — Storage management and disk operations.
configuration TestFileReg {
    param(
            [string]$source,
            [string]$destination,
            [string[]]$computername
        )
     Import-DscResource –ModuleName 'PSDesiredStateConfiguration'
     Node $computerName {
        File Netlogon {
            Ensure = "Present" 
            Type = "Directory" # Default is "File"
            Force = $True
            Recurse = $True
            SourcePath = $source
            DestinationPath = $destination  

           
        }

        File AppShare{
                 
            Ensure = "Present" 
            Type = "Directory" # Default is "File"
            Force = $True
            Recurse = $True
            SourcePath = "\\251.230.240.35\appshare\test"
            DestinationPath = "C:\temp\appshare"
            Dependson = '[Registry]TestReg1','[Registry]TestReg2'

           
        }
        Registry TestReg1 #ResourceName
    {
        Key = "HKLM:\Software\MyTesting"
        ValueName = "TestName"
        ValueData = "testValue1"
        #[ DependsOn = [string[]] ]
        Ensure = "Present"
        Force = $true
        #[ Hex = [bool] ]
        ValueType = [string]"String"
    }
    Registry TestReg2 #ResourceName
    {
        Key = "HKLM:\Software\MyTesting"
        ValueName = "TestName2"
        #ValueData = "testValue2"
        #[ DependsOn = [string[]] ]
        Ensure = "Absent"
        Force = $true
        #[ Hex = [bool] ]
        ValueType = [string]"String"
    }
    }
}

TestFileReg -OutputPath c:\temp\DSC\test -destination c:\temp\netlogon -source \\201.72.64.23\netlogon\test -computername "151.123.153.140"
Start-DscConfiguration -computername "254.40.179.158","testsrv7" -Path c:\temp\dsc\test -Wait -Verbose -force
