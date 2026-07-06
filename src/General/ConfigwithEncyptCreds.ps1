# Purpose: ConfigwithEncyptCreds — General-purpose PowerShell utilities.
$ConfigData = @{
    AllNodes = @(
        @{
            NodeName = "testsrv9"
            PSDscAllowPlainTextPassword = $false
            CertificateFile = "C:\temp\TESTSRV9\TESTSRV9.CER"
            #Thumbprint = "BE5F7E5D18F44C51C2B491802F8C7CE314A0739F"
        }
    )
}

configuration TestEncrypt
{
    param([string[]]$computerName,
    [pscredential]$cred)

    node $computerName {
    service test {
        PsDscRunAsCredential = $cred
        Name =         "spooler"
        State =        "running"
    }
    }

}

$cred = Get-Credential
$comp = "testsrv9"
cd \temp
TestEncrypt -computerName $comp -ConfigurationData $ConfigData -cred $cred
start-dscconfiguration -Path .\TestEncrypt -computerName $comp -wait -verbose
Get-service spooler -computername $comp