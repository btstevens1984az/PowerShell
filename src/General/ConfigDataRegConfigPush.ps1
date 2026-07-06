# Purpose: ConfigDataRegConfigPush — General-purpose PowerShell utilities.
$computers = "testsrv10"
configuration TestRegConfig {
    param(
            [string[]]$computername
        )
     Node $allnodes.nodename #$computername
      {
        foreach ($regvalue in $ConfigurationData.NonNodeData.RegistryValues)
        {
            Registry $regvalue.description #ResourceName
            {
                Key = $regvalue.key
                ValueName = $regvalue.valueName
                ValueData = $regvalue.valuedata
                #[ DependsOn = [string[]] ]
                Ensure = "Present"
                Force = $true
                #[ Hex = [bool] ]
                ValueType = $regvalue.type
            }



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

#region DSC Configuration w/Configuration Data Snippet
$RegistryValues = Import-csv scripts:\dsc\reg.csv
$DevConfig = @{
AllNodes = 
    @(
        @{
            NodeName  = "*"
            #RegistryValues = $RegistryValues #this will duplicate
        },
        @{
            NodeName = "VM-1";
            Role     = "WebServer"
        }, 
        @{
            NodeName = "VM-2";
            Role     = "SQLServer"
        }
    );

    NonNodeData = 
    @{
        ConfigFileContents = "test"
        RegistryValues = $RegistryValues
     }   
} 
TestRegConfig -OutputPath c:\DSC\test -computername $computers -ConfigurationData $DevConfig
#Start-DscConfiguration -computername $computers -Path c:\dsc\test -Wait -Verbose -force
