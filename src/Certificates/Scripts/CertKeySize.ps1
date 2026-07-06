# Purpose: CertKeySize — PKI and certificate lifecycle operations.
cd cert:
$certs = dir -Recurse | ? PSIsContainer -eq $false
$hash1 = @{n="KeyAlgorithm";e={$_.publickey.key.KeyExchangeAlgorithm}}
$hash2 = @{n="KeySize";e={$_.publickey.key.KeySize}}
$hash3 = @{n="SignatureAlgorithm";e={$_.publickey.key.SignatureAlgorithm}}
$ModCerts = $certs | select-object subject, $hash1, $hash2, $hash3
$ModCerts | Out-GridView
