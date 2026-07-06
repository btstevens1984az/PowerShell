# Purpose: MISC-FindLargestFiles — Storage management and disk operations.
#   James Wylde 2020


#----------------------------------------------------------------------------------------#
#   Modules

#### GB

Get-ChildItem -Recurse -ErrorAction SilentlyContinue | Sort-Object -Descending -Property Length | Select-Object -first 25 Name, @{Name="Size (GB) ";Expression={[Math]::Round($_.length / 1GB, 2)}} | Format-Table -Autosize

#### MB

Get-ChildItem -Recurse -ErrorAction SilentlyContinue | Sort-Object -Descending -Property Length | Select-Object -first 25 Name, @{Name="Size (MB) ";Expression={[Math]::Round($_.length / 1MB, 2)}} | Format-Table -Autosize

#### Export local c:\temp

Get-ChildItem -Recurse -ErrorAction SilentlyContinue | Sort-Object -Descending -Property Length | Select-Object -first 25 FullName, @{Name="Size (MB) ";Expression={[Math]::Round($_.length / 1MB, 2)}} | Export-CSV -Path C:\temp\largeFiles.csv

#### Invoke-Command to particular machine and particular user share and stored local c:\temp

Clear-Host
$clientName = Read-Host "Machine"
$userName = Read-Host "User"
Invoke-Command -ComputerName $clientName -ScriptBlock {Get-ChildItem c:\users\$using:userName\ -Recurse -ErrorAction SilentlyContinue | Sort-Object -Descending -Property Length | Select-Object -first 25 FullName, @{Name="Size (MB) ";Expression={[Math]::Round($_.length / 1MB, 2)}} | Export-CSV -NoTypeInformation -Path C:\temp\largeFiles.csv}

### Send via email with output to ts c:\

Clear-Host
$clientName = Read-Host "Machine"
$userName = Read-Host "User"
$recipientEmail = Read-Host "User Email"
Invoke-Command -ComputerName $clientName -ScriptBlock {Get-ChildItem c:\users\$using:userName\ -Recurse -ErrorAction SilentlyContinue | Sort-Object -Descending -Property Length | Select-Object -first 25 FullName, @{Name="Size (MB) ";Expression={[Math]::Round($_.length / 1MB, 2)}}} | Export-CSV -NoTypeInformation -Path C:\temp\largeFiles.csv

$outFile = "c:\temp\largeFiles.csv"
$emailBody = Get-Content $outFile | Out-String

Send-MailMessage -From 'admin@example.com' -To $recipientEmail -Subject 'Large Files' -Body -DeliveryNotificationOption OnSuccess, OnFailure $emailBody -Credential (Get-Credential "") -SmtpServer 'mail.eu.example.com' -Port 25