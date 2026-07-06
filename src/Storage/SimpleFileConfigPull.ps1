# Purpose: SimpleFileConfigPull — Storage management and disk operations.

configuration TestFile {
    param(
            [string]$source,
            [string]$destination,
            [string[]]$computername
        )
        Import-DscResource -module xDismFeature
     Node $computerName {

        xDismFeature TelnetClient {
            Name = "telnetclient"
            Ensure = "Present"

        }
     
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
           
        }
    }
}

TestFile -OutputPath c:\DSC\test -destination c:\temp\netlogon -source \\201.72.64.23\netlogon\test -computername "localhost"
$configFilePath = "C:\dsc\test\372a3afd-542d-4c9f-84d8-0293c3a14c09.mof"
copy-Item C:\dsc\test\localhost.mof $configFilePath
New-DscChecksum "C:\dsc\test" -Force
dir c:\dsc\test\372*  | Copy-Item -Destination '\\24.11.111.17\c$\Program Files\WindowsPowerShell\DscService\Configuration'
Start-Sleep -Seconds 10 #time for replication of configuration files to all pull servers
$ComputerName=1..8 | % {"testsrv$_"}
$cimSessions = New-CimSession -ComputerName $ComputerName
Update-DscConfiguration -CimSession $cimSessions -Wait
#Start-Sleep -Seconds 30 #time for new config to be applied
Get-DscConfiguration -CimSession $cimSessions | Select PScomputerName,ResourceID,Ensure | Out-GridView -Wait
#Get-DscConfigurationStatus -CimSession $cimSessions
Test-DscConfiguration -CimSession $cimSessions -Detailed | Out-GridView