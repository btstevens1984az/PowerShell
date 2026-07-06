# Purpose: MISC-TeamsBroke — Microsoft 365 tenant administration.


Get-Process -ProcessName Teams -ErrorAction SilentlyContinue | Stop-Process -Force Start-Sleep -Seconds 1 Get-Process -ProcessName Outlook -ErrorAction SilentlyContinue | Stop-Process -Force Start-Sleep -Seconds 1 Get-Process -ProcessName OneDrive -ErrorAction SilentlyContinue | Stop-Process -Force Start-Sleep -Seconds 1 Get-Process -ProcessName OneNote -ErrorAction SilentlyContinue | Stop-Process -Force Start-Sleep -Seconds 1 Get-Process -ProcessName Excel -ErrorAction SilentlyContinue | Stop-Process -Force Start-Sleep -Seconds 1 Get-Process -ProcessName POWERPNT -ErrorAction SilentlyContinue | Stop-Process -Force Start-Sleep -Seconds 1 Get-Process -ProcessName Word -ErrorAction SilentlyContinue | Stop-Process -Force Start-Sleep -Seconds 1 Get-Process -ProcessName msedge -ErrorAction SilentlyContinue | Stop-Process -Force Start-Sleep -Seconds 1 Get-Process -ProcessName lync -ErrorAction SilentlyContinue | Stop-Process -Force


cmdkey /list | ForEach-Object{if($_ -like "Target:"){cmdkey /del:($_ -replace " ","" -replace "Target:","")}}


try{ Get-ChildItem -Path $env:APPDATA\"Microsoft\teams\blobstorage" | Remove-Item -Recurse -ErrorAction SilentlyContinue Get-ChildItem -Path $env:APPDATA\"Microsoft\teams\databases" | Remove-Item -Recurse -ErrorAction SilentlyContinue Get-ChildItem -Path $env:APPDATA\"Microsoft\teams\cache" | Remove-Item -Recurse -ErrorAction SilentlyContinue Get-ChildItem -Path $env:APPDATA\"Microsoft\teams\gpucache" | Remove-Item -Recurse -ErrorAction SilentlyContinue Get-ChildItem -Path $env:APPDATA\"Microsoft\teams\Indexeddb" | Remove-Item -Recurse -ErrorAction SilentlyContinue Get-ChildItem -Path $env:APPDATA\"Microsoft\teams\Local Storage" | Remove-Item -Recurse -ErrorAction SilentlyContinue Get-ChildItem -Path $env:APPDATA\"Microsoft\teams\tmp" | Remove-Item -Recurse -ErrorAction SilentlyContinue Write-Host "Teams Cache Cleaned" }catch{ echo $ }


$Regkeypath= "HKCU:\Software\Microsoft\Office\Teams" $value = (Get-ItemProperty $Regkeypath).HomeUserUpn -eq $null If ($value -eq $False) { Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Office\Teams" -Name "HomeUserUpn" Write-Host "The registry value Sucessfully removed" } Else { Write-Host "The registry value does not exist"}


$TeamsFolders = "$env:APPDATA\Microsoft\teams" try{ $SourceDesktopConfigFile = "$TeamsFolders\desktop-config.json" $desktopConfig = (Get-Content -Path $SourceDesktopConfigFile | ConvertFrom-Json) } catch{ Write-Host "Failed to open Desktop-config.json" }


Write-Host "Modify desktop-Config.Json" try{ $desktopConfig.isLoggedOut = $true $desktopConfig.upnWindowUserUpn =""; #The email used to sign in $desktopConfig.userUpn =""; $desktopConfig.userOid =""; $desktopConfig.userTid = ""; $desktopConfig.homeTenantId =""; $desktopConfig.webAccountId=""; $desktopConfig | ConvertTo-Json -Compress | Set-Content -Path $SourceDesktopConfigFile -Force } catch{ Write-Host "Failed to overwrite desktop-config.json" } Write-Host "Modify desktop-Config.Json - Finished"


Get-ChildItem "$TeamsFolders\Cookies" | Remove-Item


Get-ChildItem "$TeamsFolders\storage.json" | Remove-Item


$LocalPackagesFolder ="$env:LOCALAPPDATA\Packages" $AADBrokerFolder = Get-ChildItem -Path $LocalPackagesFolder -Recurse -Include "Microsoft.AAD.BrokerPlugin_*"; $AADBrokerFolder = $AADBrokerFolder[0]; Get-ChildItem "$AADBrokerFolder\AC\TokenBroker\Accounts" | Remove-Item -Recurse -Force


Start-Process -FilePath "C:\Users\$env:UserName\AppData\Local\Microsoft\Teams\current\Teams.exe" Start-Process -FilePath "C:\Users\$env:UserName\AppData\Local\Microsoft\OneDrive\OneDrive.exe" exit ~~~