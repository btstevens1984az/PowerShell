# Purpose: ExportPublickKey — Network diagnostics, DNS, DHCP, and connectivity.
$certificates = dir Cert:\LocalMachine\my

$certificates | %{
    # Verify the certificate is for Encryption and valid
    if ($_.PrivateKey.KeyExchangeAlgorithm -and $_.Verify())
    {
        # Create the folder to hold the exported public key
        $folder= Join-Path -Path $env:SystemDrive\ -ChildPath $using:publicKeyFolder
        if (! (Test-Path $folder))
        {
            md $folder | Out-Null
        }

        # Export the public key to a well known location
        $certPath = Export-Certificate -Cert $_ -FilePath (Join-Path -path $folder -childPath "EncryptionCertificate.cer") 

        # Return the thumbprint, and exported certificate path
        return @($_.Thumbprint,$certPath);
    }
    }
