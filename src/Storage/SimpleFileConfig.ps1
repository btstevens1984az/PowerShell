# Purpose: SimpleFileConfig — Storage management and disk operations.
configuration TestFileReg {
    param(
            [string]$source,
            [string]$destination,
            [string[]]$computername
        )
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
           
        }

    }
}

TestFile -OutputPath c:\DSC\test -destination c:\temp\netlogon -source \\201.72.64.23\netlogon\test -computername "151.123.153.140"
Start-DscConfiguration -computername "151.123.153.140" -Path c:\dsc\test -Wait -Verbose -force
