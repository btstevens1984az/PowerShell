# Purpose: Update-Windows — General-purpose PowerShell utilities.
$dir = 'C:\temp'
mkdir $dir
$webClient = New-Object System.Net.WebClient
$url = 'https://go.microsoft.com/fwlink/?LinkID=799445'
$file = "$($dir)\Windows10Upgrade.exe"
$webClient.DownloadFile($url,$file)
Start-Process -FilePath $file -ArgumentList '/quietinstall /skipeula /auto upgrade /copylogs $dir'

Write-Host "Automatically starting update now, PC will auto reboot once it has completed."