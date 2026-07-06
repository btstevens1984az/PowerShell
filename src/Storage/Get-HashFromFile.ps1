cls
<#
   Developed by Steven Holtman in Powershell
   Website: https://StevenHoltman.com
   Get the latest scripts at https://github.com/stevenholtman
.Synopsis
   Performs System Health Checks and Pushes Results to NinjaRMM
.DESCRIPTION
    This will get the Wireless Network status as well as the network the computer is connected too. Runs internet speed test then creates performance analytics off prior results, checks for Bluescreens within the last 24 hours and sends the results, checks local printers for any errors.
    Copy this script to NinjaRMM Scripting Editor and overwrite the System Health Checks, modify the Scheduled Scripts under Device Policy's for Workstations to change the reporting interval.
#>

#Random pause to prevent network overhead
start-sleep -Seconds (900 | get-random)

#Wireless Network Information
try {
    $WirelessConnectionState = Invoke-Command -ScriptBlock { cmd /c netsh wlan show interfaces | findstr /r /s /i /m /c:"\<state\>" }
    $WirelessProfile = Invoke-Command -ScriptBlock { cmd /c netsh wlan show interfaces | findstr /r /s /i /m /c:"\<ssid\>" }
    Ninja-Property-Set wirelessNetworkInformation "Connection State: $WirelessConnectionState `n Wireless Network: $WirelessProfile"
    if (!$WirelessConnectionState) {
        Ninja-Property-Set wirelessNetworkInformation "No Wireless Network Adapter Detected"
    }
}
catch {
    Write-Verbose "No Wireless Network Adapter was Detected"
}

# Internet Speed Test

# Monitoring values
$maxpacketloss = 2 #Number of lost packets to report 
$MinimumDownloadSpeed = 100 #Maximum upload to be expected
$MinimumUploadSpeed = 20 #Minumum upload to be expected

#Setting variable paths
$DownloadURL = "https://install.speedtest.net/app/cli/ookla-speedtest-1.0.0-win64.zip"
$DownloadLocation = "$($Env:ProgramData)\SpeedtestCLI"
try {
    $TestDownloadLocation = Test-Path $DownloadLocation
    if (!$TestDownloadLocation) {
        new-item $DownloadLocation -ItemType Directory -force
        Invoke-WebRequest -Uri $DownloadURL -OutFile "$($DownloadLocation)\speedtest.zip"
        Expand-Archive "$($DownloadLocation)\speedtest.zip" -DestinationPath $DownloadLocation -Force
    } 
}
catch {  
    write-verbose "The download and extraction of SpeedtestCLI failed. Error: $($_.Exception.Message)"
    exit 1
}
$PreviousResults = if (test-path "$($DownloadLocation)\LastResults.txt") { get-content "$($DownloadLocation)\LastResults.txt" | ConvertFrom-Json }
$SpeedtestResults = & "$($DownloadLocation)\speedtest.exe" --format=json --accept-license --accept-gdpr
$SpeedtestResults | Out-File "$($DownloadLocation)\LastResults.txt" -Force
$SpeedtestResults = $SpeedtestResults | ConvertFrom-Json

#Creating Objects
[PSCustomObject]$SpeedtestObj = @{
    downloadspeed = [math]::Round($SpeedtestResults.download.bandwidth / 1000000 * 8)
    uploadspeed   = [math]::Round($SpeedtestResults.upload.bandwidth / 1000000 * 8) 
    packetloss    = [math]::Round($SpeedtestResults.packetLoss)
    isp           = $SpeedtestResults.isp
    ExternalIP    = $SpeedtestResults.interface.externalIp
}
$SpeedtestHealth = @()

#Comparing against previous result. Alerting is download or upload differs more than 20%.
if ($PreviousResults) {
    if ($PreviousResults.download.bandwidth / $SpeedtestResults.download.bandwidth * 100 -le 80) { $SpeedtestHealth += "Download speed differs by 20% of previous results `n" }
    if ($PreviousResults.upload.bandwidth / $SpeedtestResults.upload.bandwidth * 100 -le 80) { $SpeedtestHealth += "Upload speed differs by 20% of previous results `n" }
}
 
#Comparing against preset variables.
if ($SpeedtestObj.downloadspeed -lt $MinimumDownloadSpeed) { $SpeedtestHealth += "Download speed is lower than $MinimumDownloadSpeed Mbps `n" }
if ($SpeedtestObj.uploadspeed -lt $MinimumUploadSpeed) { $SpeedtestHealth += "Upload speed is lower than $MinimumUploadSpeed Mbps `n" }
if ($SpeedtestObj.packetloss -gt $MaxPacketLoss) { $SpeedtestHealth += "Packetloss is higher than $maxpacketloss%" }

#Health Report
if (!$SpeedtestHealth) {
    $SpeedtestHealth = "Healthy"
}

#Output Variables Extended
$speedtestISP = "ISP Provider: ", $SpeedtestObj.isp
$DownloadResults = "Download Speed: ", $SpeedtestObj.downloadspeed, " Mbps"
$UploadResults = "Upload Speed: ", $SpeedtestObj.uploadspeed, " Mbps"
$ExternalIP = "Public IP: ", $SpeedtestObj.ExternalIP

#Write results to custom field
Ninja-Property-Set speedtestHealth $SpeedtestHealth
Ninja-Property-Set speedtestResults "$speedtestISP `n $DownloadResults `n $UploadResults `n $ExternalIP"

#BlueScreen Reports

#Setting variable paths
$DownloadURL = "https://www.nirsoft.net/utils/bluescreenview.zip"
$DownloadLocation = "$($Env:ProgramData)\BluescreenView"
$ZipFile = "bluescreenview.zip"
$ExeName = "Bluescreenview.exe"

#Downloading Zip File and Extracting Contents
try {
    $TestDownloadLocation = Test-Path $DownloadLocation
    if (!$TestDownloadLocation) {
        new-item $DownloadLocation -ItemType Directory -force
        Invoke-WebRequest -Uri $DownloadURL -OutFile "$($DownloadLocation)\$Zipfile"
        Expand-Archive "$($DownloadLocation)\$ZipFile" -DestinationPath $DownloadLocation -Force
    } 
}
catch {
    write-verbose "The download and extraction of BSODView has Failed: $($_.Exception.Message)"
    exit 1
}

Start-Process -FilePath "$($DownloadLocation)\$ZipFile\$Exename" -ArgumentList "/scomma `"$($DownloadLocation)\Export.csv`"" -Wait

#Outputing results
$BSODs = get-content "$($DownloadLocation)\Export.csv" | ConvertFrom-Csv -Delimiter ',' -Header Dumpfile, Timestamp, Reason, Errorcode, Parameter1, Parameter2, Parameter3, Parameter4, CausedByDriver | foreach-object { $_.Timestamp = [datetime]::Parse($_.timestamp, [System.Globalization.CultureInfo]::CurrentCulture); $_ }
Remove-item "$DownloadLocation\Export.csv"
 
$BSODFilter = $BSODs | where-object { $_.Timestamp -gt ((get-date).addhours(-24)) }
 
#Write results to custom field 
if (!$BSODFilter) {
    Ninja-Property-Set bluescreenResults "Healthy - No BSODs found in the last 24 hours"
}
else {
    Ninja-Property-Set bluescreenResults "Unhealthy - BSOD found. Check Diagnostics"
    $BSODFilter
}

#Check Printer Health
$Printers = get-printer
 
$PrintStatus = foreach ($Printer in $Printers) {
    $PrintJobs = get-PrintJob -PrinterObject $printer
    $JobStatus = foreach ($job in $PrintJobs) {
        if ($Job.JobStatus -ne "normal") { "Not Healthy - $($Job)" }
    }
    [PSCustomObject]@{
        PrinterName   = $printer.Name
        PrinterStatus = $Printer.PrinterStatus
        PrinterType   = $Printer.Type
        JobStatus     = $JobStatus
    }
}
 
$PrintersNotNormal = $PrinterStatus.PrinterStatus | Where-Object { $_.PrinterStatus -ne "normal" }
if (!$PrintersNotNormal) {
    Ninja-Property-Set printerHealth "Healthy - No Printer Errors found"
}
else {
    Ninja-Property-Set printerHealth "Unhealthy - Printers with errors found."
    $PrintersNotNormal
}
$JobsNotNormal = $PrinterStatus.PrinterStatus | Where-Object { $_.JobStatus -ne "normal" -and $_.JobStatus -ne $null }
if (!$JobsNotNormal) {
    Ninja-Property-Set printerJobHealth "Healthy - No Errors found within Jobs"
}
else {
    Ninja-Property-Set printerJobHealth "Unhealthy - Errors found within Jobs"
    $JobsNotNormal
}
<#
    Developed by Steven Holtman in Powershell
    Website: https://StevenHoltman.com
    Get the latest scripts at https://github.com/stevenholtman
.Synopsis
    Get's the SHA256 Hash from a file, this is helpful for adding to your AV application or to confirm file hash after download from the developers site.
.DESCRIPTION
   It will prompt for you to enter the Source Directory and Destination Directoy to validate the hashes match in both direcoties for proper data integrity
   
.EXAMPLE
   Get-FolderComparison
#>
function Get-HashFromFile {
    try {
        # Adding Form Assembly
        Add-Type -AssemblyName System.Windows.Forms
        $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{
            InitialDirectory = [Environment]::GetFolderPath('Desktop')
            Filter           = 'Any file type (*.*)|*.*|Executable Files (*.exe)|*.exe|Batch Files (*.bat)|*.bat|Powershell Files (*.ps1)|*.ps1'
            Title            = 'Select the File you need to retrieve the File Hash for'
        }
        $DialogforFile = $FileBrowser.ShowDialog()
        $GetFileName = Get-FileHash $FileBrowser.FileName
    }
    catch {
        Write-Host $_.Exception.Message
    }
    finally {
        # Defining Variables
        $FileName = ($GetFileName.Path).split('\')[-1]
        $FileHash = $GetFileName.hash
        Write-Output "$FileName's hash: $FileHash"
    }
}