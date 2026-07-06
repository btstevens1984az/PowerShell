# Purpose: RemoveHostFromePO — Security auditing and compliance checks.
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true} # Causes WebClient to ignore certification validation
$Credential = Get-Credential -Credential "$env:USERDOMAIN\$env:USERNAME"
$WebClient = New-Object System.Net.WebClient
$WebClient.Credentials = $Credential.GetNetworkCredential()
$ePOServer = "https://epo.example.com:8443"  # Configure for your environment
$Computer = Read-Host -Prompt "Enter PC name or username"
$SearchURL = "$ePOServer/remote/system.delete?names=$Computer&:output=xml"
[XML]$ResultXML = $WebClient.DownloadString($SearchURL).Replace("OK:`r`n","")
$ResultXML.result.list.element.CmdReturnStatus | select-object name,message,@{Name="Username";expression={$env:USERNAME}} | export-csv "\\186.189.182.154\share\logs\output.csv" –NoTypeInformation -Append