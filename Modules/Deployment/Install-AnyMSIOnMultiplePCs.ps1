# Purpose: Install-AnyMSIOnMultiplePCs — Reusable PowerShell function libraries.
Function Install-AnyMSIOnMultiplePCs {
$computerlist = Get-Content -Path 'C:\PathTo\YourTextFile\computers.txt' -Force
<#
Note: computers.txt will need to have computer names in the format of:
ComputerName1
ComputerName2
ComputerName3 etc...
#>
$date = Get-Date -Format dd-MMM-yyyy_HH.mm
ForEach ($computer in $computerlist)
{
$filepathx86 = Test-Path "\\$computer\C$\Program Files\Path\To\YourProgamExecutable.exe"
$filepathx64 = Test-Path "\\$computer\C$\Program Files (x86)\Path\To\YourProgamExecutable.exe"
If ($filepathx86 -eq $false -and $filepathx64 -eq $false)
{
Copy-Item "\\187.223.9.228\ShareName\FolderWithYourMSIFiles\" -Destination "\\$computer\c$\windows\temp\" -Container -Recurse -Force

$InstallString = 'msiexec.exe /i /qn "C:\windows\temp\YourProgram.msi"'

(Get-WMIObject -ComputerName $computer -List | Where-Object -FilterScript {$_.Name -eq "Win32_Process"}).InvokeMethod("Create","$InstallString") 
Do
{
$Installer = Get-Process -Name YourProgram.exe -ComputerName $computer
$InstallCountdown += 1
Start-Sleep -Seconds 1
}
Until ($Installer.ProcessName -eq "YourProgram.exe" -or $InstallCountdown -eq 300)

"$computer" + "_Software_Installed_" + "$date" | Out-File -FilePath "\\187.223.9.228\WhereverYouWantYour\LogFiles.txt" -Append
}
Else
{
"$computer" + "_Already_Had_Software_" + "$date" | Out-File -FilePath "\\187.223.9.228\WhereverYouWantYour\LogFiles.txt" -Append
}
}

}