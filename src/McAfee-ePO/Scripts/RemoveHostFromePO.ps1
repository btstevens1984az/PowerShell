# Purpose: RemoveHostFromePO — McAfee ePolicy Orchestrator reporting.
param (
	[Parameter(Mandatory = $false, Position = 1, ValueFromPipeline = $true)]
	[String[]]$Servers
)
BEGIN {
	[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true} # Causes WebClient to ignore certification validation
	$Credential = Get-Credential -Credential "$env:USERDOMAIN\$env:USERNAME"
	$WebClient = New-Object System.Net.WebClient
	$WebClient.Credentials = $Credential.GetNetworkCredential()
	$ePOServer = "https://epo.websiteURL.com:8443"
	if (-not $Servers) {
		$Servers = Read-Host -Prompt "Enter servers [seperated by a comma, if multiple] OR`nType `"file`" to point to a file with names OR`nJust press Enter to exit"
		if ($Servers -eq "") { exit }
		elseif ($Servers -eq "file") {
			[void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
			$FileDialog = New-Object System.Windows.Forms.OpenFileDialog
			$FileDialog.Title = "Please select a file"
			$FileDialog.InitialDirectory = "U:\"
			$FileDialog.Filter = "Text files (*.txt)|*.txt"
			$Result = $FileDialog.ShowDialog()
			if ($Result -eq "OK") {
				$FilePath = $FileDialog.FileName
				$Servers = Get-Content $FilePath | ForEach-Object { $_.Trim() } | Where-Object { [String]::IsNullOrWhiteSpace($_) -eq $false } | Select-Object -Unique
			}
			else { exit }
		}
		else {
			$Servers = $Servers.Split(",").Trim()
		}
    }
}
PROCESS {
	$CSVServers = $Servers -join ","
	$Date = Get-Date -Format F
	$SearchURL = "$epoServer/remote/system.delete?names=$CSVServers&:output=xml"
	[XML]$ResultXML = $WebClient.DownloadString($SearchURL).Replace("OK:`r`n","")
	$ResultObj = $ResultXML.result.list.element.CmdReturnStatus | Select-Object Name,Message,@{Name="Username";expression={$env:USERNAME}},@{name="Date";expression={$Date}}
	$ResultObj | Export-Csv -Path "\\87.43.232.114\Removing Host from ePO\Hostname Removed from ePO.csv" -Append -NoTypeInformation
}
END {
	$Body = "
	$CSVServers removed from ePO by $env:USERDOMAIN\$env:USERNAME on $Date

	Regards,

	Administrator"
	$Recipients = "E-mail Address"
	$MailMessageSettings = @{
		To = $Recipients
		From = "ePO E-mail Distribution Address"
		SmtpServer = "SMTPServer"
		Subject = "$CSVServers Removed from ePO"
		Body = $Body
	}
	Send-MailMessage @MailMessageSettings
	$ResultObj | Out-GridView -Wait
}