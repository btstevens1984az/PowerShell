# Purpose: RemoveHostFromePOv1 — McAfee ePolicy Orchestrator reporting.
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true} # Causes WebClient to ignore certification validation
$Credential = Get-Credential -Credential "$env:USERDOMAIN\$env:USERNAME"
$WebClient = New-Object System.Net.WebClient
$WebClient.Credentials = $Credential.GetNetworkCredential()
$ePOServer = "https://epo.example.com"
$Computer = Read-Host -Prompt "Enter PC name or username"
$SearchURL = "$epoServer/remote/system.delete?names=$Computer&:output=xml"
[XML]$ResultXML = $WebClient.DownloadString($SearchURL).Replace("OK:`r`n","")
$ResultXML.result.list.element.CmdReturnStatus | select-object name,message,@{Name="Username";expression={$env:USERNAME}} | export-csv "\\160.116.63.220\Removing Host from ePO\Hostname Removed from ePO.csv" –NoTypeInformation -Append
