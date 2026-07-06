# Purpose: SimpleFileConfigPush — Storage management and disk operations.

configuration TestFile {
    param(
            [string]$source,
            [string]$destination,
            [string[]]$computername
        )

     #Node $computerName {

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
   # }
}

TestFile -OutputPath c:\DSC\test -destination c:\temp\netlogon -source \\201.72.64.23\netlogon\test -computername "localhost"
Start-DscConfiguration -computername "254.40.179.158" -Path C:\dsc\test -Wait -Verbose -force
